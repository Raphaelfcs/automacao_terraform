// App web (PWA) de documentos de saúde. Sem framework e sem dependências externas.
// Login: Cognito Hosted UI com authorization code + PKCE (sem segredo no navegador).
// Tokens ficam só na sessionStorage da aba (somem ao fechar) e nada da API vai para cache.

const $ = (s) => document.querySelector(s);
const sessao = {
  get: (k) => { try { return JSON.parse(sessionStorage.getItem(k)); } catch { return null; } },
  set: (k, v) => { try { sessionStorage.setItem(k, JSON.stringify(v)); } catch {} },
  limpar: () => { try { sessionStorage.clear(); } catch {} },
};
let CFG = null;

const b64url = (buf) => btoa(String.fromCharCode(...new Uint8Array(buf))).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
const aleatorio = (n = 32) => b64url(crypto.getRandomValues(new Uint8Array(n)));
const sha256 = async (dados) => crypto.subtle.digest("SHA-256", typeof dados === "string" ? new TextEncoder().encode(dados) : dados);
const hex = (buf) => [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, "0")).join("");

function aviso(msg) { const a = $("#aviso"); a.textContent = msg; a.hidden = !msg; }

// ------------------------------------------------------------------ autenticação
async function entrar(tipo) {
  const c = CFG.cognito[tipo];
  const verificador = aleatorio(48), estado = aleatorio(16);
  sessao.set("pkce", { verificador, estado, tipo });
  const q = new URLSearchParams({
    response_type: "code", client_id: c.client_id, redirect_uri: location.origin + "/",
    scope: "openid email", state: estado, code_challenge: b64url(await sha256(verificador)), code_challenge_method: "S256",
  });
  location.assign(`https://${c.dominio}/oauth2/authorize?${q}`);
}

async function concluirLogin() {
  const q = new URLSearchParams(location.search);
  if (!q.get("code")) return;
  const pkce = sessao.get("pkce");
  history.replaceState(null, "", "/");
  if (!pkce || q.get("state") !== pkce.estado) { aviso("Login inválido. Tente de novo."); return; }
  const c = CFG.cognito[pkce.tipo];
  const r = await fetch(`https://${c.dominio}/oauth2/token`, {
    method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({ grant_type: "authorization_code", client_id: c.client_id, code: q.get("code"),
                                redirect_uri: location.origin + "/", code_verifier: pkce.verificador }),
  });
  if (!r.ok) { aviso("Não foi possível concluir o login."); return; }
  const t = await r.json();
  sessao.set("tokens", { tipo: pkce.tipo, access: t.access_token, exp: Date.now() + t.expires_in * 1000 });
  sessionStorage.removeItem("pkce");
}

function sair() {
  const t = sessao.get("tokens"); sessao.limpar();
  const c = CFG.cognito[t?.tipo || "paciente"];
  location.assign(`https://${c.dominio}/logout?${new URLSearchParams({ client_id: c.client_id, logout_uri: location.origin + "/" })}`);
}

async function api(caminho, opcoes = {}) {
  const t = sessao.get("tokens");
  if (!t || Date.now() > t.exp - 30000) { sessao.limpar(); mostrar("entrada"); throw new Error("Sessão expirada. Entre de novo."); }
  const r = await fetch(`/api${caminho}`, { ...opcoes, headers: { ...(opcoes.headers || {}), Authorization: `Bearer ${t.access}`,
                                                                  "Content-Type": "application/json" }, cache: "no-store" });
  const corpo = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(corpo.erro || `Erro ${r.status}`);
  return corpo;
}

// ------------------------------------------------------------------ telas
function mostrar(id) {
  for (const s of ["entrada", "paciente", "equipe"]) $("#" + s).hidden = s !== id;
  $("#sair").hidden = id === "entrada";
}

function item(titulo, detalhe, acao) {
  const li = document.createElement("li");
  const txt = document.createElement("div");
  const b = document.createElement("b"); b.textContent = titulo;
  const s = document.createElement("small"); s.textContent = detalhe;
  txt.append(b, s); li.append(txt);
  if (acao) li.append(acao);
  return li;
}

function botao(texto, fn, classe = "secundario") {
  const b = document.createElement("button"); b.textContent = texto; b.className = classe;
  b.addEventListener("click", async () => { b.disabled = true; try { await fn(); } catch (e) { aviso(e.message); } finally { b.disabled = false; } });
  return b;
}

const ROTULO = { exame: "Exame", diagnostico: "Diagnóstico", receita: "Receita" };
const data = (ms) => new Date(ms).toLocaleDateString("pt-BR");

async function baixar(d) {
  const r = await api(`/v1/documentos/${d.clinica_id}/${d.documento_id}/download`);
  location.assign(r.url); // URL assinada de 60 s; o PDF baixa como anexo
}

async function telaPaciente(filtro = "") {
  mostrar("paciente");
  const { documentos } = await api("/v1/eu/documentos");
  const ul = $("#lista-docs"); ul.replaceChildren();
  const vis = documentos.filter((d) => !filtro || d.tipo === filtro).sort((a, b) => b.criado_em - a.criado_em);
  if (!vis.length) ul.append(item("Nenhum documento ainda", "Quando a clínica enviar, ele aparece aqui."));
  for (const d of vis) ul.append(item(d.titulo, `${ROTULO[d.tipo]} · ${data(d.criado_em)}`, botao("Abrir PDF", () => baixar(d), "primario")));
  const { acessos } = await api("/v1/eu/acessos");
  const ua = $("#lista-acessos"); ua.replaceChildren();
  for (const a of acessos) ua.append(item(a.acao === "download" ? "Documento aberto" : "Documento enviado",
                                          `${new Date(a.em).toLocaleString("pt-BR")} · ${a.ator_tipo === "paciente" ? "você" : "equipe da clínica"}`));
}

let pacienteAtual = null;
async function telaEquipe() {
  mostrar("equipe");
  const { pacientes } = await api("/v1/pacientes");
  const ul = $("#lista-pacientes"); ul.replaceChildren();
  if (!pacientes.length) ul.append(item("Nenhum paciente cadastrado", "Use o formulário acima."));
  for (const p of pacientes) {
    ul.append(item(p.nome, `cadastrado em ${data(p.atualizado_em)}`, botao("Documentos", async () => {
      pacienteAtual = p; $("#envio-nome").textContent = p.nome; $("#form-envio").hidden = false;
      const { documentos } = await api(`/v1/pacientes/${p.paciente_id}/documentos`);
      $("#envio-status").textContent = `${documentos.length} documento(s) deste paciente.`;
    })));
  }
}

async function enviar(form) {
  const arq = form.arquivo.files[0];
  if (!arq || arq.type !== "application/pdf") throw new Error("Escolha um arquivo PDF.");
  const bytes = await arq.arrayBuffer();
  $("#envio-status").textContent = "Preparando envio…";
  const r = await api("/v1/documentos", { method: "POST", body: JSON.stringify({
    paciente_id: pacienteAtual.paciente_id, tipo: form.tipo.value, titulo: form.titulo.value, tamanho: arq.size, sha256: hex(await sha256(bytes)) }) });
  const e = r.envio;
  let ok;
  if (e.metodo === "POST") { // S3: formulário assinado; o arquivo vai por último
    const fd = new FormData(); for (const [k, v] of Object.entries(e.campos)) fd.append(k, v); fd.append("file", arq);
    ok = (await fetch(e.url, { method: "POST", body: fd })).ok;
  } else { // GCS: PUT com os cabeçalhos assinados
    ok = (await fetch(e.url, { method: "PUT", headers: e.cabecalhos, body: arq })).ok;
  }
  $("#envio-status").textContent = ok ? "Enviado. O documento fica disponível ao paciente após a validação automática." : "Falha no envio.";
  form.reset();
}

// ------------------------------------------------------------------ início
async function iniciar() {
  CFG = await (await fetch("/config.json", { cache: "no-store" })).json();
  document.querySelectorAll("[data-login]").forEach((b) => b.addEventListener("click", () => entrar(b.dataset.login)));
  $("#sair").addEventListener("click", sair);
  document.querySelectorAll("[data-filtro]").forEach((b) => b.addEventListener("click", () => {
    document.querySelectorAll("[data-filtro]").forEach((x) => x.classList.toggle("ativo", x === b));
    telaPaciente(b.dataset.filtro).catch((e) => aviso(e.message));
  }));
  $("#form-paciente").addEventListener("submit", async (ev) => {
    ev.preventDefault();
    const f = ev.target;
    try { await api("/v1/pacientes", { method: "POST", body: JSON.stringify({ nome: f.nome.value, email: f.email.value }) }); f.reset(); await telaEquipe(); }
    catch (e) { aviso(e.message); }
  });
  $("#form-envio").addEventListener("submit", (ev) => { ev.preventDefault(); enviar(ev.target).catch((e) => aviso(e.message)); });
  if ("serviceWorker" in navigator) navigator.serviceWorker.register("/sw.js").catch(() => {});

  await concluirLogin();
  const t = sessao.get("tokens");
  if (!t) return mostrar("entrada");
  try { t.tipo === "paciente" ? await telaPaciente() : await telaEquipe(); } catch (e) { aviso(e.message); }
}

iniciar().catch(() => aviso("Não foi possível carregar o app."));

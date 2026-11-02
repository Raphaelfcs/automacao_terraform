// CloudFront Function (viewer-request): rotas do client-side router (ex.: /pedidos/123)
// não existem no bucket. Qualquer URI sem extensão de arquivo é reescrita para /index.html;
// assets com extensão seguem intactos.
function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (uri.startsWith('/api/')) {
    return request;
  }

  var lastSegment = uri.substring(uri.lastIndexOf('/') + 1);
  if (lastSegment.indexOf('.') === -1) {
    request.uri = '/index.html';
  }

  return request;
}

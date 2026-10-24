/// Construction des liens de partage vers un ticket.
///
/// Le conteneur Docker sert le client web à l'origine de l'API : une URL
/// complète et partageable est donc toujours dérivable de l'URL du serveur
/// (origine courante sur le web, URL configurée sur desktop / mobile).
library;

/// URL complète pointant vers la page de consultation d'un ticket,
/// ex. `http://localhost:8381/#/tickets/UVO-3`.
String buildTicketShareUrl(String serverBaseUrl, String ticketRef) {
  var clean = serverBaseUrl;
  while (clean.endsWith('/')) {
    clean = clean.substring(0, clean.length - 1);
  }
  return '$clean/#/tickets/$ticketRef';
}

import 'package:beez/models/event_model.dart';
import 'package:beez/models/user_model.dart';
import 'package:beez/services/firebase_service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';

class LinksUtil {
  static void shareUser(UserModel user) async {
    final SocialMetaTagParameters params = SocialMetaTagParameters(
        title: "Beez - Perfil de ${user.name}",
        imageUrl:
            user.profilePic.isNotEmpty ? Uri.parse(user.profilePic) : null);

    final link = await FirebaseService.createLink(
        "https://beezapp.page.link/profile?id=${user.id}", params);
    Share.share(
        "Acesse o Beez e descubra os eventos que seus amigos e conhecidos estão interessados!\n\n${link.shortUrl.toString()}");
  }

  static void shareEvent(EventModel event) async {
    final SocialMetaTagParameters params = SocialMetaTagParameters(
        title: "Beez - Evento: ${event.name}",
        imageUrl: event.photos.isNotEmpty ? Uri.parse(event.photos[0]) : null);

    final link = await FirebaseService.createLink(
        "https://beezapp.page.link/event?id=${event.id}", params);
    Share.share(
        "Acesse o Beez e veja tudo sobre os melhores eventos da sua região!\n\n${link.shortUrl.toString()}");
  }
}

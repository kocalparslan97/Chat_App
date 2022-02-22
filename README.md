# Android Chat App

  TR - Anlık mesajlaşma uygulaması gerçekleştirmek. 
  EN - Performing an instant messaging application.

## Getting Started

Proje nasıl çalışıyor ?

Projeyi ilk çalıştırdığımız zaman başta yükleme ekranıyla karşılaşıyoruz. Yükleme işlemi tamamlandığında login ekranı yüklenmektedir. 
“Sign in with Google” butonuna tıklayarak cihazımızda bulunan mevcut Google hesaplarımızdan birisiyle giriş yaptıktan sonra ana sayfa ekranımız yüklenmektedir.
Kullanıcıların Google ile giriş yapmasına ve kullanıcı verilerini Firebasestore’a kaydetmesine izin verme işlemlerini gerçekleştirdik.
Ana sayfamızın içeriğinde koyu ve açık tema değişimini yapabilmek amacıyla “toggle” butonuyla kullanıcının değiştirebilmesini sağladık.
Ana sayfa içerisine arama çubuğu ekledik. Uygulamaya Google hesabıyla giriş yapan kayıtlı kullanıcıları liste şeklinde ve ayrıca kullanıcının
profil resmini, kullanıcı adını ve hakkında bölümünde yazan bilgileri ana sayfa ekranımızda gösterdik. Ana sayfamıza bir de ek olarak menü çubuğu ekledik. 
Bu menü çubuğunun içerisinde “Settings” ve “Sign Out” kısımları bulunmaktadır.”Settings” seçeneğine tıkladığımızda Google hesabıyla
giriş yapan mevcut kullanıcının kullanıcı adını, hakkında kısmını, telefon numarası, alan kodu bilgilerini güncelleyebileceği alanlar
bulunmaktadır. Mevcut kullanıcı ana sayfa da liste şeklinde bulunan kullanıcılar arasından mesajlaşmak istediği kişiyi seçerek sohbet
ekranına geçiş yapacaktır. Sohbet ekranında mesaj yazacağı alanda cihazının galerisinden resim ekleyebileceği kamera butonunu
tanımladık ayrıca gönderilen ve alınan resmin üzerine tıkladığımızda tam ekran olarak görünmesini sağladık. Aynı hizada sticker
gönderebilmesi için sticker alanı ekledik. Gönderme işlemi için gönder butonu ekledik. Bu şekilde projemizi tamamladık.

This project is a starting point for a Flutter application.

How does the project work ? 

When we first run the project, we first encounter the installation screen. The login screen is loaded when the installation process is complete. 
After clicking on the ”Sign in with Google" button and logging in with one of our existing Google accounts located on our device, our home screen is loaded.
We have implemented operations to allow users to log in with Google and save user data to the Firebasestore.
In order to change the dark and light theme in the content of our homepage, we have provided that the user can change it with the “toggle” button.
We have added a search bar to the main page. dec. The application lists registered users who are logged in with a Google account, as well as the user's
we have displayed the profile picture, username and information about it in the section on our main page screen. We have added a menu bar to our homepage as an october. 
There are “Settings” and “Sign Out” sections in this menu bar.When we click on the ”Settings" option, we will
fields where the current user who is logged in can update their username, about them, phone number, area code information
is available. The current user can also chat by selecting the person he wants to message from among the users in the form of a list on the main page Dec
it will switch to the screen. In the area where he will write a message on the chat screen, click the camera button where he can add an image from his device's gallery
we also defined it and made sure that the sent and received image appears in full screen when we click on it. Flush sticker
we have added a sticker field so that he can send it. We have added a send button for the sending process. This is how we completed our project.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

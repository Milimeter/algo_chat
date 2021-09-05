class UnboardingContent {
  String image;
  String title;
  String discription;

  UnboardingContent({this.image, this.title, this.discription});
}

List<UnboardingContent> contents = [
  UnboardingContent(
    title: 'Easy Exchange',
    image: 'assets/1.svg',
    discription: "Powered by Algorand"
  ),
  UnboardingContent(
    title: 'Easy to Use',
    image: 'assets/2.svg',
    discription: "Powered by Algorand"
  ),
  UnboardingContent(
    title: 'Connect with Others',
    image: 'assets/3.svg',
    discription: "Powered by Algorand"
  ),
];
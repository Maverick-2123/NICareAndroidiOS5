

class UserModel{
  final String? id;
  final String Access;
  final String Email;
  final String Field;
  final String Name;

  const UserModel({
    this.id,
    required this.Access,
    required this.Email,
    required this.Field,
    required this.Name,
});
  toJson(){
    return {"Access":Access, "Email":Email,"Field":Field,"Name":Name};
  }


}


//here we want to create our own error in which whenever the error
// is printed somewhere, it prints the message that has been provided in the HttpException(message)
//and this error object made by us can also be thrown or rethrown any where we want.

class HttpException implements Exception{

  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
    // return super.toString(); //prints "Instance of HttpException"
  }
}
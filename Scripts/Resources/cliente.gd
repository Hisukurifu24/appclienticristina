extends Resource
class_name Cliente

var nominativo: String
var foto: Texture
var data_di_nascita: Dictionary[String, int] = {
    "giorno": 1,
    "mese": 1,
    "anno": 2000
}
var indirizzo: String
var numero_di_telefono: String
var email: String
var trattamenti: Array[Trattamento] = []
var autocura: String

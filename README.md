![Swift HTTP](http://storage.j0.hn/swift-http-logo.png)

> Beautiful HTTP requests in swift

__Examples:__

```swift
// Simple GET
http.get( "http://google.com", callback: { error, data in
  // Handle error : NSError?, data : AnyObject?
})

// POST some JSON
http
  .url("http://my-api.com/users")
  .json()
  .data([
    "name": "Bob"
  , "age":  32
  ]).post( callback: { error, data in
    // ...
  })
```

[Checkout more examples](#more-examples)

## API

There are two components to the API: A static struct named `http` and a class called `HttpRequest`. `http` provides an entry-point and factory methods to create instances of `HttpRequest`. Each method on `HttpRequest` is replicated on `http` to provide a seamless experience. Additionally, each method on `HttpRequest` returns the instance.

TODO

## More Examples

### Serializing/Deserializing Data Structures

```swift
struct User {
  id        : Int?
  firstName : String
  lastName  : String
  age       : Int

  // Serializes object to JSON
  func toJSON() -> String {
    return "{" 
      + "\"firstName\": \"" + self.firstName + "\""
      + ", \"lastName\": \"" + self.lastName + "\""
      + ", \"age\": " + (self.age as String)
      + "}"
  }
}

var bob = User(
  id:         nil
, firstName:  "Bob"
, lastName:   "Bill"
, age:        42
)

var usersHttp = http
  .url("http://myapp.com/api/users")
  .json()
  // Serializers must return NSData
  // Use the built-in toNSData serializer to go from String->NSData
  .serializer({ data in
    // data is instance of User
    return http.serializers.toNSData( data.toJSON() )
  }).deserializer({ data in
    // Parse as a dictionary first, then create User object
    let user = http.deserializers.toDictionary( data )

    // Deserializer as instance of User
    return User(
      id:         user["id"]
    , firstName:  user["firstName"]
    , lastName:   user["last`Name"]
    , age:        user["age"]
    )
  })

// ...

// Will now serialize/deserialize User objects
usersHttp.post( bob, { error, bob in
  // bob.id == SOME_INT_FROM_SERVER
})
```

## Disclaimer

I wrote this as a learning experience and for a personal application. Definitely not production-ready! But if you like the way it looks, feel free to make some contributions.

## License

MIT
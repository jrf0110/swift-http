import Foundation

typealias Callback = ( NSError?, AnyObject? ) -> Void
typealias Serializer = ( AnyObject ) -> NSData
typealias Deserializer = ( NSData ) -> AnyObject

class HttpRequest {
  var session       : NSURLSession
  var req           : NSMutableURLRequest
  var _url          : NSURL?
  var task          : NSURLSessionDataTask?
  var body          : AnyObject?
  var resBody       : NSData?
  var _serializer   : Serializer
  var _deserializer : Deserializer
  
  var isJSON = false
  
  init (){
    self.req = NSMutableURLRequest()
    self.session = NSURLSession.sharedSession()

    self._serializer = http.serializers.toNSData
    self._deserializer = http.deserializers.toString
    
    self.req.HTTPBody = http.serializers.toNSData("")
  }
  
  func serializer( callback : Serializer ) -> HttpRequest {
    self._serializer = callback
    return self
  }
  
  func deserializer( callback : Deserializer ) -> HttpRequest {
    self._deserializer = callback
    return self
  }
  
  func url( _url: NSURL ) -> HttpRequest {
    self._url = _url
    self.req.setValue( self._url, forKey: "URL" )
    return self
  }
  
  func url( _url : String ) -> HttpRequest {
    return self.url( NSURL( string: _url ) )
  }
  
  func header( key : String, value : String ) -> HttpRequest {
    self.req.addValue(value, forHTTPHeaderField: key)
    return self
  }
  
  func json() -> HttpRequest {
    self.header( "Content-Type", value: "application/json" )
    self.header( "Accept", value: "application/json" )
    self.isJSON = true
    self._serializer = http.serializers.json
    return self
  }
  
  func data( data: AnyObject ) -> HttpRequest {
    var error : NSError?
    self.body = data
    
    return self
  }
  
  func send( url: String?, data: AnyObject?, callback: Callback ) -> HttpRequest {
    if ( req.HTTPMethod != "GET" && self.body ){
      req.HTTPBody = self._serializer( self.body! )
    }
    
    NSLog( req.HTTPMethod + " " + req.URL.absoluteString )
    
    self.task = self.session.dataTaskWithRequest(
      self.req
    , completionHandler: { _data, response, error in
        self.resBody = _data
      
        if ( error ){
          NSLog( "%@", error.localizedDescription );
        }
      
        if ( _data ){
          NSLog( NSString( data: _data, encoding: NSUTF8StringEncoding ) )
        }
      
        if ( error ){
          callback( error, nil )
        } else {
          callback( nil, self._deserializer( _data ) )
        }
      }
    )
    
    self.task!.resume()
    
    return self
  }
  
  func post( url: String?, data: AnyObject?, callback: Callback? ) -> HttpRequest {
    self.req.HTTPMethod = "POST"
    
    if ( url ){
      self.url( url! )
    }
    
    if ( data ){
      self.data( data! )
    }
    
    if ( callback ){
      self.send( url, data: data, callback: callback! )
    }

    return self
  }
  
  func post( callback: Callback? ) -> HttpRequest {
    return self.post( nil, data: nil, callback: callback )
  }
  
  func get( url: String?, callback: Callback? ) -> HttpRequest {
    self.req.HTTPMethod = "GET"
    
    if ( url ){
      self.url( url! )
    }
    
    if ( callback ){
      self.send( url, data: nil, callback: callback! )
    }
    return self
  }
  
  func put( url: String?, data: AnyObject?, callback: Callback? ) -> HttpRequest {
    self.req.HTTPMethod = "PUT"
    
    if ( url ){
      self.url( url! )
    }
    
    if ( data ){
      self.data( data! )
    }
    
    if ( callback ){
      self.send( url, data: data, callback: callback! )
    }

    return self
  }
  
  func patch( url: String?, data: AnyObject?, callback: Callback? ) -> HttpRequest {
    self.req.HTTPMethod = "PATCH"
    
    if ( url ){
      self.url( url! )
    }
    
    if ( data ){
      self.data( data! )
    }
    
    if ( callback ){
      self.send( url, data: data, callback: callback! )
    }

    return self
  }
  
  func del( url: String?, callback: Callback? ) -> HttpRequest {
    self.req.HTTPMethod = "DELETE"
    
    if ( url ){
      self.url( url! )
    }
    
    if ( callback ){
      self.send( url, data: nil, callback: callback! )
    }

    return self
  }
}

struct http {
  struct serializers {
    static func json( data: AnyObject ) -> NSData {
      var error : NSError?
      return NSJSONSerialization.dataWithJSONObject( data, options: nil, error: &error )
    }
    
    static func toNSData( data: AnyObject ) -> NSData {
      return ( data as String ).dataUsingEncoding( NSUTF8StringEncoding, allowLossyConversion: false )!
    }
  }
  
  struct deserializers {
    static func toString( data: NSData ) -> AnyObject {
      return NSString( data: data, encoding: NSUTF8StringEncoding )
    }
    
    static func toDictionary( data:NSData ) -> AnyObject {
      var strData = http.deserializers.toString( data ) as String
      return http.JSON.parseDictionary( strData )
    }
  }
  
  // JSON function implementations found here:
  // https://medium.com/swift-programming/4-json-in-swift-144bf5f88ce4
  struct JSON {
    static func parseDictionary(jsonString:String) -> Dictionary<String, AnyObject> {
      var e: NSError?
      var data:NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
      var jsonObj = NSJSONSerialization.JSONObjectWithData(
        data,
        options: NSJSONReadingOptions(0),
        error: &e) as Dictionary<String, AnyObject>
      if e {
        return Dictionary<String, AnyObject>()
      } else {
        return jsonObj
      }
    }
    
    static func parseArray(jsonString: String) -> Array<AnyObject> {
      var e: NSError?
      var data: NSData!=jsonString.dataUsingEncoding(NSUTF8StringEncoding)
      var jsonObj = NSJSONSerialization.JSONObjectWithData(
        data,
        options: NSJSONReadingOptions(0),
        error: &e) as Array<AnyObject>
      if e {
        return Array<AnyObject>()
      } else {
        return jsonObj
      }
    }
  }
  
  static func url( url : String ) -> HttpRequest {
    return HttpRequest().url( url )
  }
  
  static func data( data : AnyObject ) -> HttpRequest {
    return HttpRequest().data( data )
  }
  
  static func json() -> HttpRequest {
    return HttpRequest().json()
  }
  
  static func header( key: String, value: String ) -> HttpRequest {
    return HttpRequest().header( key, value: value )
  }
  
  static func get( url : String?, callback : Callback? ) -> HttpRequest {
    return HttpRequest().get( url, callback: callback )
  }
  
  static func post( url : String?, data : AnyObject?, callback : Callback? ) -> HttpRequest {
    return HttpRequest().post( url, data: data, callback: callback )
  }
  
  static func put( url : String?, data : AnyObject?, callback : Callback? ) -> HttpRequest {
    return HttpRequest().put( url, data: data, callback: callback )
  }
  
  static func patch( url : String?, data : AnyObject?, callback : Callback? ) -> HttpRequest {
    return HttpRequest().patch( url, data: data, callback: callback )
  }
  
  static func del( url : String?, callback : Callback? ) -> HttpRequest {
    return HttpRequest().del( url, callback: callback )
  }
}

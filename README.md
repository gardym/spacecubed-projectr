                                                                             
                                    _/                        _/             
     _/_/_/    _/  _/_/    _/_/          _/_/      _/_/_/  _/_/_/_/  _/  _/_/
    _/    _/  _/_/      _/    _/  _/  _/_/_/_/  _/          _/      _/_/     
   _/    _/  _/        _/    _/  _/  _/        _/          _/      _/        
  _/_/_/    _/          _/_/    _/    _/_/_/    _/_/_/      _/_/  _/         
 _/                            _/                                            
_/                          _/                                               


Spacecubed's Projectr
=====================

Sources:
- Twitter Streaming API - by specified terms
- Twitter Streaming API - by user
- Instagram - Polling

Get projecting:
- git clone
- bundle install
- mongod
- cp sample.env .env && (Edit it with your settings)
- foreman start

Everything runs inside an EventMachine reactor (don't block it)
Sources are streamed in preference, or polled as required
Hit localhost:8080/client to checkout a sample client

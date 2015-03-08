# wlist

A command-line tool for interacting with Wunderlist’s REST- and JSON-based API. It’s currently under initial development, but is already useful as a developer exploration tool, especially when used with the `-t` flag to display the `curl` statements used.

![Screenshoot of wlist](screenshot.png)

There are two goals for `wlist`:
 
1. Provide an easy to use way to explore the API and its output for developers
2. Allow shell scripting of the API for integrations, especially with JSON tools like `jq`

Comfort with dealing with JSON data structures is assumed.

 
## Requirements

To use this tool, you’ll need the following:

* Ruby, should be on your system
* A client id. You can get one at the [Wunderlist Developer Site](https://developer.wunderlist.com/applications). Once you have it, you’ll want to set it in the `WLIST_CLIENT_ID` environment variable.
* An access token. This is tough right now. We’re going to fix this ASAP.

If you try to use `wlist` without a `WLIST_CLIENT_ID` set, you’ll get gently nudged in the right direction:


    bash-3.2$ bin/wlist inbox
    Missing $WLIST_CLIENT_ID in environment
    Visit https://developer.wunderlist.com/applications and create an app!

Likewise with the access token

    bash-3.2$ bin/wlist inbox 
    Missing $WLIST_ACCESS_TOKEN in environment. 
    
## An example walk through

Coming soon.
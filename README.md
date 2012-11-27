twit2prowl
==========

Introduction
------------
When I installed prowl on my iPhone, I originally used it together with Sickbeard and Couchpotato to receive notifications for when a new episode of my favorite series had been downloaded. I had never really thought about push notifications beyond email and quite like the functionality. Since I don't use the standard Twitter client on my iPhone, I didn't have push notifications for any mentions. Putting 2 and 2 together, why not see if I can use Prowl for that! I found some scripts which might be able to do it. However, the amount of dependencies for what seemed like something so simple were ridiculous. So, what do you do as an engineer with the NIH syndrome? Exactly: you start scripting yourself.

How it works
------------
Twit2prowl works pretty simple: every time it runs, it will fetch the last 10 mentions for your userid. It keeps a cache of the last mention it pushed and will subsequently push any new ones to prowl. As you can understand from this, if you've had more than 10 mentions since the last run you'll end up missing some. If you are that popular though, you should probably look at something more manageable anyway ;)

Installation
------------
Twit2prowl depends on two non-default Perl modules, being Net::Twitter::Lite (for communication with the Twitter API) and LWP::UserAgent (for pushing messages to Prowl via their https API). You should be able to get these from either your OS repository, or from CPAN. I personally run this on a FreeBSD machine, which means I installed p5-Net-Twitter-Lite and p5-LWP-Protocol-https from the ports tree. 

Configuration
-------------
You will need to communicate both with the Twitter as well as the Prowl API. Both require an API key, which you'll have to add to twit2prowl.conf. I've included a config example called twit2prowl.conf-dist whcih should give you enough information on the format. NB: twit2prowl WILL NOT WORK if you don't change this file! 

So, where do y u get these API keys? For Twitter:
* Go to https://dev.twitter.com/apps
* Go to "My Applications" (top right menu, hover over your avatar)
* Click 'Create a new application'
* Fill out all the details. The name needs to be unique, I suggest something like twit2prowl_<your twitter user id>
* You should now have a new application! If you click on it, you'll notice your 'consumer_tokens' information under 'OAuth settings' and your 'access_tokens' information under 'Your access token'

For Prowl:
* Go to https://www.prowlapp.com/api_settings.php (you might need to login first)
* Although you can use an existing one, I'd suggest creating a new one. This way, you can revoke access per application if you ever need to.
* Done! Paste your API key into the config file

You can now add the following line to your crontab to have it run every minute (
and to redirect any output to twit2prowl.log):
* * * * * cd <location-to-twit2prowl>; ./twit2prowl.pl >>twit2prowl.log 2>&1

To do
-----
Twit2prowl is by no means a finished product. It works for me, but might not work for you. The only reason I put it up on Guthub is because I wanted to get some experience with Github. However, these are the things I plan on improving:
* Make retrieving mentions more efficient
* Make twit2prowl work for DM's as well

You are free to send in any suggestions, or clone this repo and code your own! I can be reached on git@buum.nl. 

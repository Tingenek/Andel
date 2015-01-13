/**********************************
* Andel - Sharing Resources
* Mark Lawson @tingenek Nov 2014
* for llamas everywhere
**********************************/

Here’s my demo application Andel. The app runs with the code in the file system.

Ver 1.01
Fixed in-line tags in summary.
Ver 1.0 
First Version


Deployment is as follows:

1) Unzip the application into a suitable folder on the server file system that’s readable by the ML server.
2) Create a forest/database on the server, I used ‘andel’
	a) Turn on wildcard and collection lexicon indexes.
	b) Add range indexes for elements tag(string) owner(string) and modified(date)
3) Create a http app-server pointing to the database, I used ‘andel’ again on port 8014. 
	a) Point it’s modules directory to the application directory from 1)
4) Create a REST app-server to point to the database. I used port andel-rest on port 8005
	a) I set the security on the rest server to application-level and used an admin user as default.

Load data (these are in the folder resources/data):

Run the url http://[host]:8014/util/loadme.xqy as a suitable user - it should reply with a list of file paths

At this point http://[host]:8014/  should show you the search screen.

Modifications:

The web-app doesn’t care what port it’s on, but the index.xqy code needs to be modified if the REST server isn’t on localhost:8005 like so:
1) Open index.xqy 
2) Alter line 15 as appropriate for REST host:port.

Usage:

The app is a simple resource sharing system. It creates ‘index cards’ to point to resources in the organisation, and is intended as the start of a grass-roots deployment.
It provides Person/Link/Notes/Place cards and a facetted-search system to find them.
 
To create a card:

1) From search click on ‘New Share’ it will open in a new tab
2) Fill in the three boxes as appropriate to the type, there are hints on the left. Press Save/Update.
	a) If you want to create another card - use ‘New share’
	b) Users are encouraged to use #tags to decorate the Summary content. These are extracted and indexed.

To search:

1) Full text search from the query box
2) Facetted search by collection/owner/modified/tags

To edit or delete:

1) There is an edit button for each search result.
	a) Modify and re-save.
	b) Delete that card. 

Note. If you try and create a card, the app looks for a Person card with your name. If it doesn’t exist, it will re-direct you to a new-user form to create it first. 
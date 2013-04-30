(function() {

  /* Code for rendering Tweet objects borrowed from http://x5315.com. License
   * follows:
   *
   * Copyright 2012, Tom Brearley. Creative Commons Attribution-Noncommercial
   * 2.0 UK: England & Wales License. Semicolons may not be added unless
   * strictly necessary. Javascript is beautiful without them. */
  var generateLinkUrl = function(urlObject){
    return generateUrl(urlObject.url, urlObject.display_url)
  }

  var generateUrl = function(href, text){
    return "<a href='" + href + "' target='_blank'>" + text + "</a>"
  }

  var urls = {
    twitterBase: "http://api.twitter.com/1",
    twitterIntentBase: "https://twitter.com/intent",
    twitterSearchBase: "https://twitter.com/#!/search/%23"
  }

  window.Tweet = function(jsonData){
    var entities = jsonData.entities
    this.text = jsonData.text
    this.media = entities.media || []
    this.hashtags = entities.hashtags || []
    this.urls = entities.urls || []
    this.userMentions = entities.user_mentions || []
    this.id = jsonData.id_str
    this.createdAt = new Date(jsonData.created_at)
    this.source = jsonData.source
    this.screenName = jsonData.user.screen_name
    this.replyToName = jsonData.in_reply_to_screen_name
    this.replyToId = jsonData.in_reply_to_status_id_str
  }

  Tweet.prototype.sourceSpan = function(){
    var appendString = this.inReplyTo()
    return "<span class='nonblock'>" + this.generateTweetUrl(moment(this.createdAt).fromNow()) + "</span>"
  }

  Tweet.prototype.inReplyTo = function(){
    if(this.replyToName && this.replyToId){
      return " &middot; " + this.generateTweetUrl("in reply to @" + this.replyToName, this.replyToId, this.replyToName)
    }
    return ""
  }

  Tweet.prototype.generateTweetUrl = function(text, otherTweet, otherName){
    otherTweet = otherTweet || this.id
    otherName = otherName || this.screenName
    return generateUrl("https://twitter.com/" + otherName + "/status/" + otherTweet, text)
  }

  Tweet.prototype.generateScreenNameUrl = function(otherName){
    screenName = otherName || this.screenName
    return "@" + generateUrl("https://twitter.com/" + screenName, screenName)
  }

  Tweet.prototype.renderReplyLink = function(){
    return generateUrl(urls.twitterIntentBase + "/tweet?in_reply_to=" + this.id + "&text=I saw your Vine on Vpeeker!&related=madebypxi", "")
  }

  Tweet.prototype.renderRetweetLink = function(){
    return generateUrl(urls.twitterIntentBase + "/retweet?tweet_id=" + this.id + "&related=madebypxi", "")
  }

  Tweet.prototype.renderFavouriteLink = function(){
    return generateUrl(urls.twitterIntentBase + "/favorite?tweet_id=" + this.id + "&related=madebypxi", "")
  }

  Tweet.prototype.renderVerbIcons = function(){
    var verbIcons = [this.renderReplyLink(), this.renderRetweetLink(), this.renderFavouriteLink()]
    return "<span class='nonblock verb_icons'>" + verbIcons.join("") + "<a href='#' class='fbshare'></a></span>"
  }

  Tweet.prototype.useEntities = function(){
    var substrings = {},
    findSubstring = function(entity, text){
      var indices = entity.indices
      return text.substring(indices[0], indices[1])
    }

    this.media.forEach((function(medium){
      var mediaSubstring = findSubstring(medium, this.text)
      substrings[mediaSubstring] = generateLinkUrl(medium)
    }).bind(this))
    this.hashtags.forEach((function(hashtag){
      var hashtagSubstring = findSubstring(hashtag, this.text)
      substrings[hashtagSubstring] = generateUrl(urls.twitterSearchBase + hashtag.text, hashtagSubstring)
    }).bind(this))
    this.urls.forEach((function(url){
      var urlSubstring = findSubstring(url, this.text)
      substrings[urlSubstring] = generateLinkUrl(url)
    }).bind(this))
    this.userMentions.forEach((function(mention){
      var userSubstring = findSubstring(mention, this.text)
      substrings[userSubstring] = this.generateScreenNameUrl(mention.screen_name)
    }).bind(this))
    for(var i in substrings){
      this.text = this.text.replace(i, substrings[i])
    }

    return this
  }

  Tweet.prototype.toString = function(){
    return "<p>" + this.text + "<br />" + this.sourceSpan() + this.renderVerbIcons() + "</p>"
  }
})();

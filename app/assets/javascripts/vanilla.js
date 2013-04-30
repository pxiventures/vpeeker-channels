//= require tweet

(function() {

  window.queued = window.swapping = false;
  window.curVideo = window.nextVideo = false;

  // Public: Share a Vine on Facebook. Expects JS object that looks like the 
  // data we get from the backend.
  window.shareOnFacebook = function(vine) {
    if (typeof vine === "undefined") { vine = curVideo; }

    Analytics.trackEvent('Facebook', 'Clicked to share');

    // TODO: Remove this code duplication (this is in save_vines.js too).
    var base_url = vine.video_url.match(/\/videos\/(.+)$/)[1],
        thumbnail_url = "https://vines.s3.amazonaws.com/thumbs/" + base_url + ".jpg",

        obj = {
          method: 'feed',
          redirect_uri: gon.root_url + 'closeDialog.html',
          link: vine.vine_url,
          picture: thumbnail_url,
          name: 'A Vine by @' + vine.tweet.user.screen_name,
          caption: vine.tweet.text
        };

    FB.ui(obj, function(response) {
      if (response.post_id) {
        Analytics.trackEvent('Facebook', 'Came back from sharing');
      }
    });
  };



  window.swapVideo = function() {
    if (!nextVideo || (curVideo && curVideo.video_url == nextVideo.video_url)) {
      // Just rewind the video
      Player.currentTime(0);
      Player.play();
      Analytics.trackEvent('Vines', 'Play', 'duplicate');
    } else {
      nextVideo.tweetString = new Tweet(nextVideo.tweet).useEntities();
      $(".metadata").html(ich.videoTemplate(nextVideo));
      Player.src({type: "video/mp4", src: nextVideo.video_url});
      Player.play();
      curVideo = nextVideo;
      Analytics.trackEvent('Vines', 'Play', 'new');
    }
    $.ajax({
      type: "GET",
      url: gon.videos_path,
      cache: false,
      success: function(data) {
        nextVideo = data;
      },
      failure: function() {
        nextVideo = false;
      },
      dataType: "json"
    });
  };

  window.resizeVideo = _.bind(function() {
    var videoContainerSize = $("#video").width();
    if (typeof Player !== "undefined") {
      Player.size(videoContainerSize, videoContainerSize);
    }
    $("#border").height(videoContainerSize - 10).width(videoContainerSize - 10);
  }, window);

  window.toggleFullscreen = function(e) {
    $("body").toggleClass("fullscreen");
    $(this).tooltip("hide");
    resizeVideo();
    e.preventDefault();
  };

  window.toggleMute = function(e) {
    Player.volume(window.muteState === 0 ? 1 : 0);
    window.muteState = Player.volume();
    $(".buttons .mute i").toggleClass("hidden");
    e.preventDefault();
  };

  $(function() {

    resizeVideo();

    _V_("videoplayer").ready(function(){

      window.Player = this;
      
      // set mute state from channel default mute
      if (_V_.defaultMute) { 
        Player.volume(0); 
        $(".buttons .mute i").toggleClass("hidden");
      }
      
      window.muteState = Player.volume();
      Player.addEvent("loadeddata", Player.play);
      Player.addEvent("ended", window.swapVideo);
      Player.addEvent("play", function() {
        $(".vjs-controls, .vjs-big-play-button").css({opacity: 0}).removeClass("vjs-fade-in");
        // Fix for Firefox to ensure we are muted.
        Player.volume(window.muteState);
      });
      resizeVideo();

      $.ajax({
        method: "GET",
        url: gon.videos_path,
        data: {reset: "true"},
        cache: false,
        success: function(data) {
          nextVideo = data;
          curVideo = undefined;
          swapVideo();
        }
      });
    });

    $(window).on("orientationchange", window.resizeVideo);
    $("#video .buttons a").tooltip();

    $(window).resize(_.throttle(window.resizeVideo, 1000));
    $(".fullscreen").click(window.toggleFullscreen);
    $(".mute").click(window.toggleMute);

    $(".metadata").on("click", ".fbshare", function() { window.shareOnFacebook(); });

    twttr.ready(function (twttr) {
      _.each(['favorite', 'tweet', 'retweet'], function(e) {
        twttr.events.bind(e, function(twitterEvent) {
          Analytics.trackEvent('Twitter', e, twitterEvent.tweet_id || twitterEvent.source_tweet_id || twitterEvent.screen_name);
        });
      });
    });

  });

})();

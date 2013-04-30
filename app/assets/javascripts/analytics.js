(function() {

  window.Analytics = window.Analytics || {};
  window._gaq = window._gaq || [];

  // Public: track an event with Google Analytics.
  //
  // category - Event category, required
  // action   - Event action, required
  // label    - Event label, optional.
  //
  // Returns false if category or action are missing (so you can safely use
  // the function without it raising an exception).
  Analytics.trackEvent = function(category, action, label) {
    if (!category || !action) { return false; }
    eventData = ['_trackEvent', category, action];
    t2eventData = ['t2._trackEvent', category, action];
    if (label) { eventData.push(label); t2eventData.push(label); }

    _gaq.push(eventData, t2eventData);
  };

  // Public: Forcefully track an event.
  //
  // Takes all the same arguments as #trackEvent. The final argument /must/
  // be a callback function to run after the event has been tracked.
  //
  // Example:
  //
  //   # Analytics.forceTrackEvent(
  //     "Page",
  //     "Reloaded",
  //     function() { window.location.reload(); }
  //   );
  //   # => Sends 'Page Reloaded' event then reloads the page.
  //
  // Because this uses a small delay to achieve the desired result, some JS may
  // fail in the callback. For example opening a new popup is often blocked by
  // browsers because it is considered an advert opening without direct user
  // interaction.
  Analytics.forceTrackEvent = function() {
    var callback = Array.prototype.slice.call(arguments, -1)[0];
    if (!_.isFunction(callback)) {
      throw "Analytics.forceTrackEvent must be supplied with a callback function as the last parameter";
    }
    try {
      Analytics.trackEvent.apply(Analytics, Array.prototype.slice.call(arguments, 0, -1));
    } catch(err) {}

    setTimeout(callback, 100);
  };

})();

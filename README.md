# Vpeeker Channels

This is the code that originally powered [Vinepeek Channels][]. It is a
subscription service that allows customers to create their own 'channels' of
Vines a la [Vinepeek][].

As part of our sunsetting policy, we are open-sourcing the code for the
community to use and improve upon if anyone wishes to.

**This code, while complete, is rough around the edges as it is more or less a
direct open-sourcing of a private project. As a result, some quirks may remain
and the code may not be strictly portable from the environment it was run in.**

## High level overview

 - Channels are owned by users, who are tied to a Twitter account. Channels
   have some basic configuration tied to them, most importantly the 'filter'
   which filters videos to only the ones the user wants on their channel.
 - Channels are populated with Videos which are fetched via the Twitter Search
   API at regular intervals (the interval is dynamic based on the activity
   of the filter).
 - Videos are displayed to users of the channel in a semi-random way, ensuring
   they mostly view recent videos.
 - What a user can and cannot do is controlled by what Plan they are on. 
   Plans are customised by admins.

## Requirements

Vpeeker Channels requires the following elements:

 - Ruby 1.9.3.
 - Rails 3.2.
 - PostgreSQL
 - The ability to handle long-running processes (The default is to spawn from
   Unicorn).
 - A Fastspring account for payments & subscriptions.
 - Some Twitter application credentials.

It has been tested and deployed on Heroku, and should run there with minimum
fuss.

## Installation notes

 - Vpeeker Channels was built to be run on a subdomain. If this isn't the case,
   make sure to change `config.action_dispatch.tld_length` back to 1 in
   `config/environemnts/production.rb`.
 - The first user to sign in will be an admin.

## Configuration

Configuration is done through environment variables. References to these
variables and their use are in `config/config.yml`.

## Fastspring

Fastspring is used for payment processing. You must set up custom HTTP callback
notifications within Fastspring. Documentation for these still needs to be
written, for now look at `subscriptions_controller.rb` and work out what fields
are used.

[Vinepeek Channels]: http://channels.vinepeek.com
[Vinepeek]: http://vinepeek.com

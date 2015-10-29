Slack = require 'slack-client'
models = require './models'

token = 'xoxb-12902597654-5iHlSdLENvmqdDAdhfzR7tC2'
autoReconnect = true
autoMark = true

slack = new Slack(token, autoReconnect, autoMark)

slack.on 'open', ->
  channels = []
  groups = []
  unreads = slack.getUnreadCount()

  # Get all the channels that bot is a member of
  channels = ("##{channel.name}" for id, channel of slack.channels when channel.is_member)

  # Get all groups that are open and not archived 
  groups = (group.name for id, group of slack.groups when group.is_open and not group.is_archived)

  console.log "Welcome to Slack. You are @#{slack.self.name} of #{slack.team.name}"
  console.log 'You are in: ' + channels.join(', ')
  console.log 'As well as: ' + groups.join(', ')

  messages = if unreads is 1 then 'message' else 'messages'

  console.log "You have #{unreads} unread #{messages}"


slack.on 'message', (message) ->
  channel = slack.getChannelGroupOrDMByID(message.channel)
  user = slack.getUserByID(message.user)
  response = ''

  {type, ts, text} = message

  channelName = if channel?.is_channel then '#' else ''
  channelName = channelName + if channel then channel.name else 'UNKNOWN_CHANNEL'

  userName = if user?.name? then "@#{user.name}" else "UNKNOWN_USER"

  console.log """
    Received: #{type} #{channelName} #{userName} #{ts} "#{text}"
  """

  # Respond to messages
  if type is 'message' and text? and channel?

    should_respond = (text) ->
      return /benbot/i.test(text)

    should_record = (text) ->
      return /record/i.test(text)

    can_record = (text) ->
      matches = text.match(/\"|\”|\“/g);
      count = if matches then matches.length else 0
      if count != 2
        return false
      else
        return true

    should_help = (text) ->
      return /help/i.test(text)

    record = (text) ->
      quote = text.match(/(\"|\“)(.*)(\"|\”)/i)
      console.log(quote)
      models.record(quote[0].slice(1, -1))
      channel.send "Thanks, I'm going to start saying: " + quote[0]

    help = () ->
      channel.send "I know how to: \'record \"things in quotes\"\''. Otherwise I just say pick-nitty things." 

    send = (quotes) ->
      console.log quotes
      text = [quote for quote in quotes].join(" \n")
      channel.send text
      console.log """
        @#{slack.self.name} responded with "#{text}"
      """

    if should_respond(text)
      if should_record(text)
        if can_record(text)
          record(text)
        else 
          channel.send 'Sorry, could you say that again with two quotes "(example)"?'
      else if should_help(text)
        help()
      else # Default behavior: send quote
        models.quote(send)

  else
    #this one should probably be impossible, since we're in slack.on 'message' 
    typeError = if type isnt 'message' then "unexpected type #{type}." else null
    #Can happen on delete/edit/a few other events
    textError = if not text? then 'text was undefined.' else null
    #In theory some events could happen with no channel
    channelError = if not channel? then 'channel was undefined.' else null

    #Space delimited string of my errors
    errors = [typeError, textError, channelError].filter((element) -> element isnt null).join ' '

    console.log """
      @#{slack.self.name} could not respond. #{errors}
    """

slack.on 'error', (error) ->
  console.error "Error: #{error}"

slack.login()
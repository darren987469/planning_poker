class PokerChannel < ApplicationCable::Channel
  def subscribed
    event = {
      type: 'user_join',
      params: params
    }
    service = PokerGameService.new(event)
    if service.run
      stream_from(service.stream_key)
    end
  end

  def unsubscribed
    event = {
      type: 'user_leave',
      params: params
    }
    PokerGameService.new(event).run
  end

  def receive(event)
    PokerGameService.new(event).run
  end
end

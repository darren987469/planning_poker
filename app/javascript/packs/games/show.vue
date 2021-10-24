<template>
  <div class="ml-3">
    <div class="row ml-3" v-if="game.status == 'voting'">
      <p>Please click the number card and vote....</p>

      <p><button v-for="card in cards"
        class="btn-border-pink col-3 mb-1"
        :key="card.title"
        @click="sendUpdateVoteEvent(card.value)">
        {{ card.title }}
      </button>
      </p>
    </div>

    <div>
      <button @click="sendUpdateGameEvent" class="ml-3 btn-pink">{{ getGameControlButtonName() }}</button>
    </div>

    <hr>
    <div v-for="vote in game.votes" :key="vote.id" class="ml-3">
      <td class="pr-3 pb-1">{{ vote.user.name }}</td>
      <td >{{ displayVote(vote) }}</td>
    </div>

  </div>
</template>

<script>
import consumer from "channels/consumer"

export default {
  props: {
    user: Object
  },
  data: function() {
    let game = this.$attrs.game

    return ({
      pokerChannel: null,
      game: game,
      cards: [
        { title: '1', value: '1' },
        { title: '2', value: '2' },
        { title: '3', value: '3' },
        { title: '5', value: '5' },
        { title: '8', value: '8' },
        { title: '13', value: '13' },
        { title: '21', value: '21' },
        { title: '34', value: '34' },
        { title: '?', value: '?' }
      ]
    })
  },

  created: function() {
    this.pokerChannel = consumer.subscriptions.create({
      channel: "PokerChannel",
      game: { id: this.game.id },
      user: { id: this.user.id }
    },
    {
      received: (data) => {
        console.log(data)
        this.game = data.game
      }
    });
  },

  methods: {
    displayVote(vote) {
      switch (this.game.status) {
        case 'not_started':
          return '-'
        case 'voting':
          if(vote.value === null)
            return 'picking the card...'
          if(vote.user.id === this.user.id) {
            return vote.value
          } else {
            return 'card picked'
          }
        case 'voting_ended':
          if(vote.value === null)
            return '?'
          else
            return vote.value
        default:
          throw 'invalid game status'
      }
    },
    displayVoteValue(value) {
      if(vote.value === null)
        return 'picking the card...'
      if(vote.user.id === this.user.id) {
        return vote.value
      } else {
        return 'card picked'
      }
    },
    currentVote() {
      return this.game.votes.find(v => v.user.id === this.user.id)
    },
    sendUpdateVoteEvent(value) {
      var event = {
        type: 'update_vote',
        params: {
          game: { id: this.game.id },
          vote: { id: this.currentVote().id, value: value },
          user: { id: this.user.id }
        }
      }
      this.pokerChannel.send(event)
    },
    sendUpdateGameEvent() {
      var event = {
        type: 'update_game',
        params: {
          game: {
            id: this.game.id,
            status: this.getGameNextStatus()
          }
        }
      }
      this.pokerChannel.send(event)
    },
    getGameNextStatus() {
      // status are [not_started, voting, voting_ended]
      switch (this.game.status) {
        case 'not_started':
          return 'voting'
        case 'voting':
          return 'voting_ended'
        case 'voting_ended':
          return 'voting'
        default:
          throw 'invalid game status'
      }
    },
    getGameControlButtonName() {
      if(this.game.status === 'voting')
        return 'Show cards'
      if(this.game.status === 'voting_ended') {
        return 'Next Vote'
      } else {
        return 'Vote Now'
      }
    }
  }
};
</script>

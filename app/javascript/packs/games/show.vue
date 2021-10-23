<template>
  <div>
    <h3>Votes</h3>
    <h3>Hi, {{user.name}}, user_id: {{user.id}}</h3>
    <table>
      <thead>
        <tr>
          <th>Name</th>
          <th>Card</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="vote in game.votes" :key="vote.id">
          <td>{{ vote.user.name }}</td>
          <td>{{ displayVote(vote) }}</td>
        </tr>
      </tbody>
    </table>

    <button
      v-for="card in cards"
      :key="card.title"
      @click="sendUpdateVoteEvent(card.value)"
      :disabled="game.status !== 'voting'">
      {{ card.title }}
    </button>

    <div>
      <button @click="sendUpdateGameEvent">{{ getGameControlButtonName() }}</button>
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
        { title: "1", value: 1 },
        { title: "2", value: 2 },
        { title: "3", value: 3 },
        { title: "5", value: 5 },
        { title: "8", value: 8 },
        { title: "13", value: 13 },
        { title: "21", value: 21 },
        { title: "34", value: 34 },
        { title: "?", value: null }
      ]
    })
  },

  created: function() {
    this.pokerChannel = consumer.subscriptions.create({
      channel: "PokerChannel",
      game: { id: this.game.id }
    },
    {
      received: (data)=> {
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
      return this.game.status === 'voting' ? 'Show cards' : 'Start new voting'
    }
  }
};
</script>

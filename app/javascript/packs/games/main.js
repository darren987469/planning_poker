import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
import GameApp from './show.vue'

Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  let element = document.getElementById("gameApp")

  if(element) {
    const user = JSON.parse(element.dataset.user)
    const game = JSON.parse(element.dataset.game)

    const app = new Vue({
      el: element,
      render: h => h(
        GameApp,
        {
          props: { user: user },
          attrs: { game: game }
        }
      )
    })
  }
})

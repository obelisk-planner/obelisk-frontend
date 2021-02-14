<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 class="mb4">Recipe</h1>
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">

      <table>
        <tr>
           <th>{{ recipe.recipe_name }}</th>
           <td>
              <router-link v-if="this.still_there" v-bind:to="'/recipe/' + this.recipe.id">
                Current Page
              </router-link>
              <div v-else>Deleted</div>
           </td>
        </tr>

        <tr>
          <td>Current consumer price:</td>
          <td>${{ recipe.consumer_price }}/unit activity</td>
        </tr>

        <tr>
          <td>
            Highest price any consumer would pay:
          </td>
          <td>${{ recipe.max_price }}/unit activity</td>
        </tr>

        <tr>
          <td>Current activity:</td>
          <td>{{ recipe.current_activity }} units activity</td>
        </tr>
      </table>
    </div>
    <p v-else-if="state == 'loading'">Loading recipe snapshot...</p>
  
 </div>
</template>

<script>

export default {
  props: ['user_jwt'],
  created() {
    this.loadRecipe();
  },
  data() {
    return {
      recipe: {},
      still_there: false,
      error: "",
      state: "loading"
    };
  },
  methods: {
    async loadRecipe() {
      try {
        const recipes = await fetch(
          'http://' + process.env.VUE_APP_API_URL + '/recipes_history?change_id=eq.'+ this.$route.path.split("/")[4],
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        const current = await fetch(
          'http://' + process.env.VUE_APP_API_URL + '/recipes?id=eq.'+ recipes[0].id + '&select=id&limit=1',
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        if (current) {this.still_there=true;}
        this.recipe = recipes[0];
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
    }
  }
};
</script>
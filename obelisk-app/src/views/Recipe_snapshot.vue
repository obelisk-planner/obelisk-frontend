<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 class="mb4">Recipe</h1>
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">

      <table>
        <tr>
           <th>{{ recipe.recipe_name }}</th>
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
      error: "",
      state: "loading"
    };
  },
  methods: {
    async loadRecipe() {
      try {
        const recipes = await fetch(
          `http://10.152.152.11:3000/recipes_history?change_id=eq.`+ this.$route.path.split("/")[4],
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
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
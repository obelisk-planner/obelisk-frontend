<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 v-if="this.$route.path.split('/').length == 4" class="mb4">Edit Recipe</h1>
  <h1 v-else class="mb4">Create Recipe</h1>
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">

      <table>
        <tr>
            <td>Recipe name:</td>
            <td><input v-model="this.recipe.recipe_name"></td>
        </tr>
        <tr>
          <td>
            <input type="checkbox" id="consumer_checkbox" v-model="is_consumer">
            <label for="consumer_checkbox">This recipe is for consumers.</label>
          </td>
          <td v-if="is_consumer">
            <input type="checkbox" id="nonessential_checkbox" v-model="is_nonessential">
            <label for="consumer_checkbox">This recipe is not an essential for consumers.</label>
          </td>
        </tr>
        <tr v-if="is_consumer">
          <td>Current consumer price:</td>
          <td>$<input v-model.number="this.recipe.consumer_price">/unit activity</td>
        </tr>

        <tr v-if="is_consumer && is_nonessential">
          <td>
            Highest price any consumer would pay:
          </td>
          <td>$<input v-model.number="this.recipe.max_price">/unit activity</td>
        </tr>

        <tr v-if="is_consumer">
          <td>Current activity:</td>
          <td><input v-model.number="this.recipe.current_activity"> units activity</td>
        </tr>
        <tr>
          <td>Delay to build up to normal production:</td>
          <td><input v-model.number="this.recipe.delay"> weeks</td>
        </tr>
        <tr>
          <td><button v-on:click="submit">Submit</button></td>
        </tr>
      </table>
    </div>
    <p v-else-if="state == 'loading'">Loading existing recipe...</p>
  
 </div>
</template>

<script>

export default {
  props: ['user_jwt'],
  created() {
    console.log(this.$route.path.split('/').length);
    if (this.$route.path.split('/').length == 4) {
      this.loadRecipe();
    } else {
      this.newRecipe();
      this.state = 'ready';
    }
  },
  data() {
    return {
      recipe: {},
      is_consumer: false,
      is_nonessential : true,
      error: "",
      state: "loading"
    };
  },
  methods: {
    newRecipe() {
        console.log('new_recipe');
        this.recipe = {
        recipe_name: '',
        consumer_price: 0,
        max_price: 0,
        current_activity: 0,
        delay: 0
      }
    },
    async loadRecipe() {
      try {
        const recipes = await fetch(
          'http://' + process.env.VUE_APP_API_URL + '/recipes?id=eq.'+ this.$route.path.split("/")[3],
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        this.recipe = recipes[0];
        this.state = "ready";
        if (this.recipe.consumer_price) {
          this.is_consumer = true;
        }
        if (this.recipe.max_price >= 5000000) {
          this.is_nonessential = false;
        }
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
    },
    async submit() {
      const new_recipe = {
        new_name: this.recipe.recipe_name,
        new_consumer_price: this.recipe.consumer_price,
        new_max_price: this.recipe.max_price,
        new_current_activity: this.recipe.current_activity,
        new_delay: this.recipe.delay
      };
      if (!this.is_consumer) {
        new_recipe.new_consumer_price = 0;
        new_recipe.new_max_price = 0;
      } else if (!this.is_nonessential) {new_recipe.new_max_price = 5000000;}
      if ('id' in this.recipe) {
        new_recipe.selected_id = this.$route.path.split("/")[3];
        try{
          await fetch('http://' + process.env.VUE_APP_API_URL + '/rpc/update_recipe', {
            method: 'POST',
            body: JSON.stringify(new_recipe),
            headers: {
              'Content-Type': 'application/json;charset=utf-8',
              'Authorization': 'Bearer ' + this.user_jwt.jwt
            }
          }).then(response => response.json());
        } catch (err) {
          this.error = err;
          this.state = "error";
        }
        this.$router.replace({ path: '/recipe/'+new_recipe.selected_id });
      } else {
        var uuid;
        try{
          uuid = await fetch('http://' + process.env.VUE_APP_API_URL + '/rpc/create_recipe', {
            method: 'POST',
            body: JSON.stringify(new_recipe),
            headers: {
              'Content-Type': 'application/json;charset=utf-8',
              'Authorization': 'Bearer ' + this.user_jwt.jwt
            }
          }).then(response => response.json());
        } catch (err) {
          this.error = err;
          this.state = "error";
        }
        this.$router.replace({ path: '/recipe/'+uuid });
      }
    }
  }
};
</script>
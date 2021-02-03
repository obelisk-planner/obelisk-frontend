<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 class="mb4">Recipe</h1>
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">

      <table>
        <tr>
           <th>{{ recipe.recipe_name }}</th>
           <div v-if="user_jwt.name">
             <td>
               <router-link v-bind:to="'/form/recipe/' + this.recipe.id">Update Basic Information</router-link>
             </td>
             <td v-if="!deleting"><button v-on:click="deleting=true">Delete</button></td>
             <td v-else>
               <p>Are you sure?</p>
               <button v-on:click="deleting=false">No</button>
               <button v-on:click="delete_recipe">Yes</button>
             </td>
           </div>
           <td>
             <router-link v-bind:to="'/history/recipe/' + this.recipe.id">See History</router-link>
           </td>
        </tr>

        <tr v-if="recipe.consumer_price != 0">
          <td>Current consumer price:</td>
          <td>${{ recipe.consumer_price }}/unit activity</td>
        </tr>

        <tr v-if="recipe.max_price < 5000000">
          <td>
            Highest price any consumer would pay:
          </td>
          <td>${{ recipe.max_price }}/unit activity</td>
        </tr>

        <tr v-if="recipe.consumer_price != 0">
          <td>Current activity:</td>
          <td>{{ recipe.current_activity }} units activity</td>
        </tr>
      </table>
      <table>
        <thead>
          <tr>
              <th colspan="2">Produces in Steady State:</th>
          </tr>
        </thead>
        <production v-for="production in recipe.productions" :key="production.id" :production="production"
        :user_jwt="user_jwt" v-on:please-reload="reload"/>
        <div v-if="user_jwt.name">
          <tr v-if="!adding_steady">
            <td><button v-on:click="open_add_steady">Add Production</button></td>
          </tr>
          <tr v-else>
            <div  v-if="'id' in prod_resource">
              <td>{{ selected_resource.resource_name }}</td>
              <td><input v-model.number="this.new_prod_value">
                {{ selected_resource.measurement_unit }}/week</td>
            </div>
            <td v-else>Select a resource from the sidebar.</td>
            <td><button v-on:click="close_add_steady">Cancel</button></td>
            <td><button v-on:click="add_production">Add</button></td>
          </tr>
        </div>
      </table>
      <table>
        <tr>
          <td>Delay to build up to normal production:</td>
          <td>{{ recipe.delay }} weeks</td>
        </tr>
      </table>
      <table>
        <thead>
          <tr>
              <th colspan="2">Produces during Startup:</th>
          </tr>
        </thead>
        <start-production v-for="s_production in recipe.starting_productions" :key="s_production.id" :production="s_production" 
        :user_jwt="user_jwt" v-on:please-reload="reload"/>
        <div v-if="user_jwt.name">
          <tr v-if="!adding_start">
            <td><button v-on:click="open_add_start">Add Production</button></td>
          </tr>
          <tr v-else>
            <div  v-if="'id' in prod_resource">
              <td>{{ selected_resource.resource_name }}</td>
              <td><input v-model.number="this.new_prod_value">
                {{ selected_resource.measurement_unit }}/week
              </td>
            </div>
            <td v-else>Select a resource from the sidebar.</td>
            <td><button v-on:click="close_add_start">Cancel</button></td>
            <td><button v-on:click="add_starting_production">Add</button></td>
          </tr>
        </div>
      </table>
      <table>
        <tr>
          <td>Activity in generated sustainable economy:</td>
          <td>{{ recipe.final_activity }} units activity</td>
        </tr>
      </table>
      <table>
        <thead>
          <tr>
              <th colspan="2">Rations in solution (negative for quotas):</th>
          </tr>
        </thead>
        <production v-for="f_production in recipe.final_productions" :key="f_production.id" 
         :user_jwt="''" :production="f_production"/>
      </table>

    </div>
    <p v-else-if="state == 'loading'">Loading recipe...</p>
  
 </div>
</template>

<script>
import Production_res from "@/components/Production_res.vue";
import Production_start_res from "@/components/Production_start_res.vue";

export default {
  props: ['prod_resource','user_jwt'],
  components: {
    'production': Production_res,
    'start-production': Production_start_res
  },
  created() {
    this.loadRecipe();
  },
  computed: {
    selected_resource: function () { // To avoid some sort of circular dependency during rendering.
      return this.prod_resource;
    }
  },
  data() {
    return {
      recipe: {},
      deleting: false,
      adding_start: false,
      adding_steady: false,
      new_prod_value: 0,
      error: "",
      state: "loading"
    };
  },
  methods: {
    async loadRecipe() {
      try {
        const recipes = await fetch(
          `http://10.152.152.11:3000/recipes?id=eq.`+ this.$route.path.split("/")[2],
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        this.recipe = recipes[0];
        console.log(this.recipe.id);
        const productions = await fetch(
          'http://10.152.152.11:3000/production?recipe_id=eq.'+this.recipe.id,
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        );
        this.recipe.productions = await productions.json();
        for (const production of this.recipe.productions) {
          var retrieved_res = await fetch(
            'http://10.152.152.11:3000/resources?id=eq.'+production.resource_id,
            {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
          ).then(response => response.json());
          production.resource = retrieved_res[0];
        }
        const starting_productions = await fetch(
          'http://10.152.152.11:3000/starting_production?recipe_id=eq.'+this.recipe.id,
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        );
        this.recipe.starting_productions = await starting_productions.json();
        for (const starting_production of this.recipe.starting_productions) {
          retrieved_res = await fetch(
            'http://10.152.152.11:3000/resources?id=eq.'+starting_production.resource_id,
            {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
          ).then(response => response.json());
          starting_production.resource = retrieved_res[0];
        }

        this.recipe.final_productions = [];
        for (const production of this.recipe.productions) {
          this.recipe.final_productions.push({
            id : production.id, resource : production.resource,
            production : -production.production * this.recipe.final_activity
          });
        }
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
    },
    async delete_recipe() {
      try{
        fetch(`http://10.152.152.11:3000/rpc/remove_recipe`, {
          method: 'POST',
          body: "{\"selected_id\":\"" + this.recipe.id + "\"}",
          headers: {
            'Content-Type': 'application/json;charset=utf-8',
            'Authorization': 'Bearer ' + this.user_jwt.jwt
          }
        });
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
      this.$router.replace({ path: '/' });
    },
    async add_production() {
      const new_prod = {
        new_recipe_id: this.recipe.id,
        new_resource_id: this.prod_resource.id,
        new_production: this.new_prod_value,
      };
      try{
        fetch(`http://10.152.152.11:3000/rpc/create_production`, {
          method: 'POST',
          body: JSON.stringify(new_prod),
          headers: {
            'Content-Type': 'application/json;charset=utf-8',
            'Authorization': 'Bearer ' + this.user_jwt.jwt
          }
        });
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
      this.$emit('click-uninsert');
      this.adding_steady = false;
      this.reload();
    },
    async add_starting_production() {
      const new_prod = {
        new_recipe_id: this.recipe.id,
        new_resource_id: this.prod_resource.id,
        new_production: this.new_prod_value,
      };
      try{
        fetch(`http://10.152.152.11:3000/rpc/create_starting_production`, {
          method: 'POST',
          body: JSON.stringify(new_prod),
          headers:  {
            'Content-Type': 'application/json;charset=utf-8',
            'Authorization': 'Bearer ' + this.user_jwt.jwt
          }
        });
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
      this.$emit('click-uninsert');
      this.adding_start = false;
      this.reload();
    },
    open_add_start() {
      this.$emit('click-insert');
      this.adding_start = true;
      this.adding_steady = false;
    },
    open_add_steady() {
      this.$emit('click-insert');
      this.adding_steady = true;
      this.adding_start = false;
    },
    close_add_start() {
      this.$emit('click-uninsert');
      this.adding_start = false;
    },
    close_add_steady() {
      this.$emit('click-uninsert');
      this.adding_steady = false;
    },
    reload() {
      this.$router.replace({ path: '/r' + this.$route.path });
    }
  }
};
</script>
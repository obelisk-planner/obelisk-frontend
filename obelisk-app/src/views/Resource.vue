<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 class="mb4">Resource</h1>
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">

      <table>
        <tr>
          <th>{{ resource.resource_name }}</th>
          <div v-if="user_jwt.name">
            <td><button v-on:click="add">Save to Sidebar</button></td>
             <td>
               <router-link v-bind:to="'/form/resource/' + this.resource.id">Update Basic Information</router-link>
             </td>
            <td v-if="!deleting"><button v-on:click="deleting=true">Delete</button></td>
            <td v-else>
              <p>Are you sure?</p>
              <button v-on:click="deleting=false">No</button>
              <button v-on:click="delete_resource">Yes</button>
            </td>
          </div>
          <td>
            <router-link v-bind:to="'/history/resource/' + this.resource.id">See History</router-link>
          </td>
        </tr>

        <tr>
          <td>Unit of measurement:</td>
          <td>{{resource.measurement_unit}}</td>
        </tr>

        <tr>
          <td>Amount produced naturally without human intervention:</td>
          <td v-if="resource.natural_production != 0">{{ resource.natural_production }} {{resource.measurement_unit}}/week</td><td v-else>None.</td>
        </tr>

        <tr>
          <td>Token representing transport of {{ resource.resource_name }}:</td>
          <td v-if="resource.transport_token != null">
            <router-link v-bind:to="'/resource/' + this.resource.token.id">{{ resource.transpot_token }}</router-link>
          </td><td v-else>None.</td>
        </tr>

        <tr v-if="resource.transport_token != null">
          <td>Transport tokens required per {{ resource.measurement_unit }}:</td>
          <td>{{ resource.tokens_required }} {{ resource.token.measurement_unit}}</td>
        </tr>
        <tr>
          <td>
            Kilograms of element 
            <select v-model="selected">
              <option v-for="element in elements" v-bind:value="element.value" v-bind:key="element.value">
                {{ element.text }}
              </option>
            </select>
            in one {{ resource.measurement_unit }} {{ resource.resource_name }}:
          </td>
          <td> {{ resource.element_content[selected] }} </td>
        </tr>
      </table>
      <table>
        <thead>
          <tr>
              <th colspan="2">Recipes using or Producing this at Steady State:</th>
          </tr>
        </thead>
        <production v-for="production in resource.productions" :key="production.id" :production="production"/>
      </table>
      <table>
        <thead>
          <tr>
              <th colspan="2">Recipes using or Producing this during Startup:</th>
          </tr>
        </thead>
        <production v-for="s_production in resource.starting_productions" :key="s_production.id" :production="s_production"/>
      </table>

    </div>
    <p v-else-if="state == 'loading'">Loading resource...</p>
  
 </div>
</template>

<script>
import Production_rec from "@/components/Production_rec.vue";

export default {
  props: ['user_jwt'],
  components: {
    'production': Production_rec
  },
  created() {
    this.loadResource();
  },
  data() {
    return {
      resource: {},
      elements: [
        { text: 'H', value: 0 },
        { text: 'He', value: 1 },
        { text: 'Li', value: 2 },
        { text: 'Be', value: 3 },
        { text: 'B', value: 4 },
        { text: 'C', value: 5 },
        { text: 'N', value: 6 },
        { text: 'O', value: 7 },
        { text: 'F', value: 8 },
        { text: 'Ne', value: 9 },
        { text: 'Na', value: 10 },
        { text: 'Mg', value: 11 },
        { text: 'Al', value: 12 },
        { text: 'Si', value: 13 },
        { text: 'P', value: 14 },
        { text: 'S', value: 15 },
        { text: 'Cl', value: 16 },
        { text: 'Ar', value: 17 },
        { text: 'K', value: 18 },
        { text: 'Ca', value: 19 },
        { text: 'Sc', value: 20 },
        { text: 'Ti', value: 21 },
        { text: 'V', value: 22 },
        { text: 'Cr', value: 23 },
        { text: 'Mn', value: 24 },
        { text: 'Fe', value: 25 },
        { text: 'Co', value: 26 },
        { text: 'Ni', value: 27 },
        { text: 'Cu', value: 28 },
        { text: 'Zn', value: 29 },
        { text: 'Ga', value: 30 },
        { text: 'Ge', value: 31 },
        { text: 'As', value: 32 },
        { text: 'Se', value: 33 },
        { text: 'Br', value: 34 },
        { text: 'Kr', value: 35 },
        { text: 'Rb', value: 36 },
        { text: 'Sr', value: 37 },
        { text: 'Y', value: 38 },
        { text: 'Zr', value: 39 },
        { text: 'Nb', value: 40 },
        { text: 'Mo', value: 41 },
        { text: 'Ru', value: 42 },
        { text: 'Rh', value: 43 },
        { text: 'Pd', value: 44 },
        { text: 'Ag', value: 45 },
        { text: 'Cd', value: 46 },
        { text: 'In', value: 47 },
        { text: 'Sn', value: 48 },
        { text: 'Sb', value: 49 },
        { text: 'Te', value: 50 },
        { text: 'I', value: 51 },
        { text: 'Xn', value: 51 },
        { text: 'Cs', value: 53 },
        { text: 'Ba', value: 54 },
        { text: 'La', value: 55 },
        { text: 'Ce', value: 56 },
        { text: 'Pr', value: 57 },
        { text: 'Nd', value: 58 },
        { text: 'Sm', value: 59 },
        { text: 'Eu', value: 60 },
        { text: 'Gd', value: 61 },
        { text: 'Tb', value: 62 },
        { text: 'Dy', value: 63 },
        { text: 'Ho', value: 64 },
        { text: 'Er', value: 65 },
        { text: 'Tm', value: 66 },
        { text: 'Yb', value: 67 },
        { text: 'Lu', value: 68 },
        { text: 'Hf', value: 69 },
        { text: 'Ta', value: 70 },
        { text: 'W', value: 71 },
        { text: 'Re', value: 72 },
        { text: 'Os', value: 73 },
        { text: 'Ir', value: 74 },
        { text: 'Pt', value: 75 },
        { text: 'Au', value: 76 },
        { text: 'Hg', value: 77 },
        { text: 'Tl', value: 78 },
        { text: 'Pb', value: 79 },
        { text: 'Bi', value: 80 },
        { text: 'Th', value: 81 },
        { text: 'U', value: 82 }

      ],
      selected: 0,
      deleting: false,
      error: "",
      state: "loading"
    };
  },

  methods: {
    async loadResource() {
      try {
        const resources = await fetch(
          `http://10.152.152.11:3000/resources?id=eq.`+ this.$route.path.split("/")[2],
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        this.resource = resources[0];
        const productions = await fetch(
          'http://10.152.152.11:3000/production?resource_id=eq.'+this.resource.id,
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        );
        this.resource.productions = await productions.json();
        for (const production of this.resource.productions) {
          var retrieved_rp = await fetch(
            'http://10.152.152.11:3000/recipes?id=eq.'+production.recipe_id,
            {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
          ).then(response => response.json());
          production.recipe = retrieved_rp[0];
          production.recipe.unit = this.resource.measurement_unit;
        }
        const starting_productions = await fetch('http://10.152.152.11:3000/starting_production?resource_id=eq.'+this.resource.id);
        this.resource.starting_productions = await starting_productions.json();
        for (const starting_production of this.resource.starting_productions) {
          retrieved_rp = await fetch(
            'http://10.152.152.11:3000/recipes?id=eq.'+starting_production.recipe_id,
            {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
          ).then(response => response.json());
          starting_production.recipe = retrieved_rp[0];
          starting_production.recipe.unit = this.resource.measurement_unit;
        }
        if (this.resource.transport_token_id != null) {
          const tokens = await fetch(
            'http://10.152.152.11:3000/resources?id=eq.'+ this.resource.transport_token_id,
            {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
          ).then(response => response.json());
          this.resource.token = tokens[0];
          console.log(this.resource.token.id);
        } else {this.resource.token = this.resource;} // So it won't complain.
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
    },
    add() {
      this.$emit('click-add', this.resource);
    },
    async delete_resource() {
      try{
        fetch(`http://10.152.152.11:3000/rpc/remove_resource`, {
          method: 'POST',
          body: "{\"selected_id\":\"" + this.resource.id + "\"}",
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
    }
  }
};
</script>
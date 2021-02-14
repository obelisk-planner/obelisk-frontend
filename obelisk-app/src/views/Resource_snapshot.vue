<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 class="mb4">Resource</h1>
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">

      <table>
        <tr>
          <th>{{ resource.resource_name }}</th>
           <td>
              <router-link  v-if="this.still_there" v-bind:to="'/resource/' + this.resource.id">
                Current Page
              </router-link>
              <div v-else>Deleted</div>
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
    </div>
    <p v-else-if="state == 'loading'">Loading resource snapshot...</p>
  
 </div>
</template>

<script>

export default {
  props: ['user_jwt'],
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
      still_there: false,
      selected: 0,
      error: "",
      state: "loading"
    };
  },

  methods: {
    async loadResource() {
      try {
        const resources = await fetch(
          'http://' + process.env.VUE_APP_API_URL + '/resources_history?change_id=eq.'+ this.$route.path.split("/")[4],
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        const current = await fetch(
          'http://' + process.env.VUE_APP_API_URL + '/resources?id=eq.'+ resources[0].id + '&select=id&limit=1',
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        if (current) {this.still_there=true;}
        this.resource = resources[0];
        if (this.resource.transport_token_id != null) {
          const tokens = await fetch(
            'http://' + process.env.VUE_APP_API_URL + '/resources_history?change_id=eq.'+ this.resource.transport_token_id,
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
    }
  }
};
</script>
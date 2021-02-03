<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 class="mb4">Resource</h1>
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">

      <table>
        <tr>
            <td>Resource name:</td>
            <td><input v-model="this.resource.resource_name"></td>
        </tr>

        <tr>
          <td>Unit of measurement:</td>
          <td><input v-model="this.resource.measurement_unit"></td>
        </tr>

        <tr>
          <td>
            <input type="checkbox" id="natural_checkbox" v-model="is_natural">
            <label for="natural_checkbox">This resource is produced naturally without human intervention</label>
          </td>
          <td v-if="is_natural">Amount produced naturally:</td>
          <td v-if="is_natural"><input v-model="this.resource.natural_production"> {{ processed_unit }}/week</td>
        </tr>
        <tr>
          <td>
            <input type="checkbox" id="token_checkbox" v-model="has_token">
            <label for="token_checkbox">This resource requires transport.</label>
          </td>
          <td v-if="has_token">Token representing transport of this resource:</td>
          <td v-if="this.resource.transport_token != '' && has_token">
            (Previously <router-link v-bind:to="'/resource/' + this.resource.token.id">{{ resource.token.resource_name }}</router-link>)
          </td>
          <td v-if="has_token">
            <div v-if="'id' in prod_resource">{{ prod_resource.resource_name }}</div>
            <div v-else>Select a resource from the sidebar.</div>
          </td>
        </tr>

        <tr v-if="has_token">
          <td>Transport tokens required per {{ resource.measurement_unit }}:</td>
          <td><input v-model="this.resource.natural_production"> {{ prod_resource.measurement_unit}}</td>
        </tr>
        <tr>
          <td>
            Kilograms of element 
            <select v-model="selected">
              <option v-for="element in elements" v-bind:value="element.value" v-bind:key="element.value">
                {{ element.text }}
              </option>
            </select>
            in one {{ processed_unit }} of this resource:
          </td>
          <td><input v-model="this.resource.element_content[selected]"></td>
        </tr>
        <tr>
          <td><button v-on:click="submit">Submit</button></td>
        </tr>
      </table>

    </div>
    <p v-else-if="state == 'loading'">Loading resource...</p>
  
 </div>
</template>

<script>

export default {
  props: ['prod_resource','user_jwt'],
  created() {
    console.log(this.$route.path.split('/').length);
    if (this.$route.path.split('/').length == 4) {
      this.loadResource();
    } else {
      this.newResource();
      this.state = 'ready';
    }
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
      has_token: false,
      is_natural: false,
      error: "",
      state: "loading"
    };
  },
  computed: {
    processed_unit: function () {
      if (this.resource.measurement_unit == '') {
        return 'unit';
      } else {
        return this.resource.measurement_unit;
      }
    }
  },
  methods: {
    newResource() {
      console.log('new_resource');
      this.resource = {
        resource_name: '',
        measurement_unit: '',
        natural_production: 0,
        transport_token: '',
        tokens_required: 0,
        element_content: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          ,0,0,0,0,0,0,0,0,0]
      }
    },
    async loadResource() {
      try {
        const resources = await fetch(
          `http://10.152.152.11:3000/resources?id=eq.`+ this.$route.path.split("/")[3],
            {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
          ).then(response => response.json());
        this.resource = resources[0];
        if (this.resource.transport_token_id) {
          this.has_token = true;
          const tokens = await fetch(
            'http://10.152.152.11:3000/resources?id=eq.'+this.resource.transport_token_id,
            {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
          ).then(response => response.json());
          this.resource.token = tokens[0];
          console.log(this.resource.token.id);
        }
        if (this.resource.natural_production) {this.is_natural = true;}
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
    },
    async submit() {
      const new_resource = {
        new_name: this.resource.resource_name,
        new_natural: this.resource.natural_production,
        new_unit: this.resource.measurement_unit,
        new_transport_token: this.prod_resource.id,
        new_tokens_required: this.resource.tokens_required,
        new_element_content: this.resource.element_content
      };
      if (!this.is_natural) {new_resource.new_natural = 0;}
      if (!this.prod_resource.id || !this.has_token) {
        new_resource.new_transport_token = null;
        new_resource.new_tokens_required = 0;
      }
      var uuid;
      if ('id' in this.resource) {
        new_resource.selected_id = this.$route.path.split("/")[3];
        uuid = this.$route.path.split("/")[3];
        fetch(`http://10.152.152.11:3000/rpc/update_resource`, {
          method: "POST",
          body: JSON.stringify(new_resource),
          headers: {
            'Content-Type': 'application/json;charset=utf-8',
            'Authorization': 'Bearer ' + this.user_jwt.jwt
          }
        });
      } else {
        try{
          uuid = await fetch(`http://10.152.152.11:3000/rpc/create_resource`, {
            method: 'POST',
            body: JSON.stringify(new_resource),
            headers: {
              'Content-Type': 'application/json;charset=utf-8',
              'Authorization': 'Bearer ' + this.user_jwt.jwt
            }
          }).then(response => response.json());
          console.log(uuid);
        } catch (err) {
          this.error = err;
          this.state = "error";
        }
      }
      this.$router.replace({ path: '/resource/'+uuid });
    }
  }
};
</script>
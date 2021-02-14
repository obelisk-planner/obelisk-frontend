<template>
 <div class="mw6 center pa3 sans-serif">
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">

      <table>
        <tr>
           <th v-if="this.steady">Recipe 
              <router-link v-bind:to="'/history/display/recipe/' + this.production.change_id">
                "{{ production.recipe_name }}"
              </router-link> Production</th>
           <th v-else>Recipe 
              <router-link v-bind:to="'/history/display/recipe/' + this.production.change_id">
                "{{ production.recipe_name }}"
              </router-link> Starting Production</th>
        </tr>

        <tr>
          <td>Resource:</td>
          <td>
            <router-link v-bind:to="'/resource/' + this.production.resource_id">
              {{ production.resource_name }}
            </router-link>
          </td>
        </tr>

        <tr>
          <td>Produces:</td>
          <td>{{ production.production }} {{ production.measurement_unit }}/week</td>
        </tr>

      </table>
    </div>
    <p v-else-if="state == 'loading'">Loading production snapshot...</p>
  
 </div>
</template>

<script>

export default {
  props: ['user_jwt'],
  created() {
    this.loadProduction();
  },
  data() {
    return {
      production: {},
      steady: false,
      error: "",
      state: "loading"
    };
  },
  methods: {
    async loadProduction() {
      try {
        const starting = await fetch(
          'http://' + process.env.VUE_APP_API_URL + '/starting_production_history?change_id=eq.'
            + this.$route.path.split("/")[4],
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        const steady = await fetch(
          'http://' + process.env.VUE_APP_API_URL + '/production_history?change_id=eq.'
            + this.$route.path.split("/")[4],
          {headers: {'Authorization': 'Bearer ' + this.user_jwt.jwt}}
        ).then(response => response.json());
        if (starting.length == 1) {
          this.production = starting[0];
        }
        if (steady.length == 1) {
          this.production = steady[0];
          this.steady = true;
        }
        var new_prop = {};
        new_prop = await fetch('http://' + process.env.VUE_APP_API_URL + '/recipes_history?changed_time=lte.' 
          + encodeURIComponent(this.production.changed_time) + '&limit=1&select=recipe_name,change_id')
            .then(response => response.json());
        this.production = Object.assign(this.production,new_prop[0]);
        new_prop = await fetch('http://' + process.env.VUE_APP_API_URL + '/resources_history?changed_time=lte.' 
          + encodeURIComponent(this.production.changed_time) + '&limit=1&select=resource_name')
            .then(response => response.json());
        this.production = Object.assign(this.production,new_prop[0]);
        new_prop = await fetch('http://' + process.env.VUE_APP_API_URL + '/resources_history?changed_time=lte.' 
          + encodeURIComponent(this.production.changed_time) + '&limit=1&select=measurement_unit')
            .then(response => response.json());
        this.production = Object.assign(this.production,new_prop[0]);
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
    }
  }
};
</script>
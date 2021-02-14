<template>
 <div class="mw6 center pa3 sans-serif">
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">   
      <table>
        <thead>
          <tr>
              <th colspan="2">
                <router-link v-bind:to="'/recipe' + this.$route.path.split('/')[3]">
                  {{ recipename }}
                </router-link>
              past actions:</th>
          </tr>
        </thead>
        <tr v-if="results.length == 0 && page == 0">
          <td>No history. (Somehow)</td>
        </tr>
        <div v-else-if="results.length == this.result_limit">
          <tr v-for="result in results" :key="result.changed_time">
            <td><router-link v-bind:to="'/history/user/' + this.result.changed_user">
              {{ result.changed_user }}
            </router-link></td>
            <td>{{ result.changed_time }}</td>
            <td v-if="result.deleted">Deletion</td>
            <td v-else>Creation/Update</td>
            <td v-if="result.is_production">
              <router-link v-bind:to="'/history/display/production/' + this.result.change_id">
                Display Production
              </router-link>
            </td>
            <td v-else>
              <router-link v-bind:to="'/history/display/recipe/' + this.result.change_id">
                Display New Basic Information
              </router-link>
            </td>
          </tr>
          <tr>
            <td v-if="this.page > 0">
              <button v-on:click="lastResults">Back</button>
            </td>
            <td>
              <button v-on:click="nextResults">Next</button>
            </td>
          </tr>
        </div><div v-else-if="results.length > 0 && this.page > 0">
          <tr><td>
              <button v-on:click="lastResults">Back</button>
          </td></tr>
        </div><div v-else-if="results.length == 0 && this.page > 0">
          <tr><td>No more history.</td></tr>
          <tr><td>
              <button v-on:click="lastResults">Back</button>
          </td></tr>
        </div><div v-else>
          <tr v-for="result in results" :key="result.changed_time">
            <td><router-link v-bind:to="'/history/user/' + result.changed_user">
              {{ result.changed_user }}
            </router-link></td>
            <td>{{ result.changed_time }}</td>
            <td v-if="result.deleted">Deletion</td>
            <td v-else>Creation/Update</td>
            <td v-if="result.is_production">
              <router-link v-bind:to="'/history/display/production/' + result.change_id">
                Display Production
              </router-link>
            </td>
            <td v-else>
              <router-link v-bind:to="'/history/display/recipe/' + result.change_id">
                Display New Basic Information
              </router-link>
            </td>
          </tr>
        </div>
      </table>
    </div>
    <p v-else-if="state == 'loading'">Loading results...</p>
 </div>
</template>

<script>

export default {
  created() {
    this.loadHistory();
  },
  data() {
    return {
      results: [],
      recipename: "",
      result_limit: 10,
      page: 0,
      error: "",
      state: "loading"
    };
  },
  methods: {
    compare_times (first,second) {
      if (first.changed_time > second.changed_time) {return 0;} else {return 1;}
    },
    async loadHistory() {
      var changes = [];
      try {
        this.recipename = await fetch('http://' + process.env.VUE_APP_API_URL + '/recipes?id=eq.' 
          + this.$route.path.split("/")[3] + '&select=recipe_name') 
            .then(response => response.json());
        this.recipename = this.recipename[0].recipe_name;
        changes = await fetch('http://' + process.env.VUE_APP_API_URL + '/recipes_history?id=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' 
          + this.result_limit + '&offset=' + this.result_limit*this.page)
            .then(response => response.json());
        changes = changes.concat(await fetch('http://' + process.env.VUE_APP_API_URL + '/production_history?recipe_id=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' + this.result_limit
          + '&offset=' + this.result_limit*this.page)
            .then(response => response.json()));
        changes = changes.concat(await fetch('http://' + process.env.VUE_APP_API_URL + '/starting_production_history?recipe_id=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' + this.result_limit
          + '&offset=' + this.result_limit*this.page)
            .then(response => response.json()));
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
      changes = changes.sort(this.compare_times);
      for (var i=0; i<changes.length; i++) {
        var change = {
          change_id: changes[i].change_id,
          deleted: changes[i].deleted,
          changed_time: changes[i].changed_time,
          changed_user: changes[i].changed_user
        };
        if (changes[i].recipe_id) {change.is_production = true;}
          else {change.is_production = false;}
        this.results.push(change);
      }
    },
    nextResults() {
      this.page++;
      this.loadHistory();
    },
    lastResults() {
      this.page--;
      this.loadHistory();
    }
  }
};
</script>
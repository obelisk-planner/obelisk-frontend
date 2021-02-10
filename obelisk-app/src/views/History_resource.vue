<template>
 <div class="mw6 center pa3 sans-serif">
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">   
      <table>
        <thead>
          <tr>
              <th colspan="2">
                <router-link v-bind:to="'/resource/' + this.$route.path.split('/')[3]">
                  {{ resourcename }}
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
            <td>
              <router-link v-bind:to="'/history/display/resource/' + result.change_id">
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
            <td>
              <router-link v-bind:to="'/history/display/resource/' + result.change_id">
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
      resourcename: "",
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
        this.resourcename = await fetch('http://10.152.152.11:3000/resources?id=eq.' 
          + this.$route.path.split("/")[3] + '&select=resource_name') 
            .then(response => response.json());
        this.resourcename = this.resourcename[0].resource_name;
        changes = await fetch('http://10.152.152.11:3000/resources_history?id=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' 
          + this.result_limit + '&offset=' + this.result_limit*this.page)
            .then(response => response.json());
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
<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 class="mb4">Search recipes</h1>
    <input v-model="query">
    <button v-on:click="startResults">Search</button>

    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">   
      <table>
        <thead>
          <tr>
              <th colspan="2">Results:</th>
          </tr>
        </thead>
        <tr v-if="results.length == 0 && page == 0">
          <td>No recipes have a name containing that.</td>
        </tr>
        <div v-else-if="results.length == this.result_limit">
          <result v-for="result in results" :key="result.id" :recipe="result"/>
          <tr>
            <td v-if="this.page > 0">
              <button v-on:click="lastResults">Back</button>
            </td>
            <td>
              <button v-on:click="nextResults">Next</button>
            </td>
          </tr>
        </div><div v-else-if="results.length > 0 && this.page > 0">
          <result v-for="result in results" :key="result.id" :recipe="result"/>
          <tr><td>
              <button v-on:click="lastResults">Back</button>
          </td></tr>
        </div><div v-else-if="results.length == 0 && this.page > 0">
          <tr><td>No more results.</td></tr>
          <tr><td>
              <button v-on:click="lastResults">Back</button>
          </td></tr>
        </div><div v-else>
          <result v-for="result in results" :key="result.id" :recipe="result"/>
        </div>
      </table>
    </div>
    <p v-else-if="state == 'loading'">Loading results...</p>
 </div>
</template>

<script>
import Result_rec from "@/components/Result_rec.vue";

export default {
  components: {
    'result': Result_rec
  },
  data() {
    return {
      results: [],
      query: "",
      current_query: "",
      result_limit: 10,
      page: 0,
      error: "",
      state: "waiting"
    };
  },
  methods: {
    async loadResults() {
      try {
        this.state = "ready";
        this.results = await fetch('http://' + process.env.VUE_APP_API_URL + '/recipes?recipe_name=like.*' 
          + this.current_query + '*' + '&limit=' + this.result_limit + '&offset=' 
          + this.result_limit*this.page)
          .then(response => response.json());
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
    },
    startResults() {
      // Current_query may seem redundant, but what if you change the query while on page three?
      // It also allows us to add any escapes that are neccesary.
      this.current_query = '';
      for (var i = 0; this.query[i] != undefined; i++) {
        if (/\w/.test(this.query[i])) {
          this.current_query = this.current_query + this.query[i];
        } else {
          this.current_query = this.current_query + '\\' + this.query[i];
        }
      }
      this.current_query = encodeURIComponent(this.current_query);
      this.page = 0;
      this.loadResults();
    },
    nextResults() {
      this.page++;
      this.loadResults();
    },
    lastResults() {
      this.page--;
      this.loadResults();
    }
  }
};
</script>
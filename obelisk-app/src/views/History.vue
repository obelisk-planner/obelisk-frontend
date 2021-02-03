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
              <th colspan="2">Past actions:</th>
          </tr>
        </thead>
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
      result_limit: 10,
      page: 0,
      error: "",
      state: "loading"
    };
  },
  methods: {
    compareTimes (first,second) {
      if (first.changed_time < second.changed_time) {return 0;} else {return 1;}
    },
    async loadHistory() {
      var changes = [];
      try {
        changes = await fetch('http://10.152.152.11:3000/recipes_history?id=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' 
          + this.result_limit + '&offset=' + this.result_limit*this.page)
            .then(response => response.json());
        changes = changes + await fetch('http://10.152.152.11:3000production_history?recipe_id=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' + this.result_limit
          + '&offset=' + this.result_limit*this.page)
            .then(response => response.json());
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
      changes = changes.sort(compare_times);
      for (var i=0; i<this.result_limit*2; i++) {
        var change = {
          change_id: changes[i].change_id,
          deleted: changes[i].deleted,
          changed_time: changes[i].changed_time,
          changed_user: changes[i].changed_user
        };
        this.results + change;
      }
    }.
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
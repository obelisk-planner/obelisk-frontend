<template>
 <div class="mw6 center pa3 sans-serif">
  <h1 class="mb4">{{  username  }}</h1>
    <p v-if="state == 'error'" class="orange">{{ error }}</p>
    <div v-else-if="state == 'ready'">   
      <table>
        <thead>
          <tr>
              <th colspan="2">Past actions:</th>
          </tr>
        </thead>
        <tr v-if="results.length == 0 && page == 0">
          <td>No history. (Somehow)</td>
        </tr>
        <div v-else-if="results.length == this.result_limit">
          <tr v-for="result in results" :key="result.changed_time">
            <td v-if="result.is_production">
              (Starting) Production in Recipe <router-link v-bind:to="'/history/recipe/' + result.id">
                {{ result.changed_name }}
              </router-link>
            </td><div v-else>
              <div v-if="result.is_recipe">
                <td>
                  Recipe <router-link v-bind:to="'/history/recipe/' + result.id">
                    {{ result.changed_name }}
                  </router-link>
                </td>
              </div>
              <div v-else>
                <td>
                  Resource <router-link v-bind:to="'/history/resource/' + result.id">
                    {{ result.changed_name }}
                  </router-link>
                </td>
              </div>
            </div>
            <td>{{ result.changed_time }}</td>
            <td v-if="result.deleted">Deletion</td>
            <td v-else>Creation/Update</td>
            <td v-if="result.is_production">
              <router-link v-bind:to="'/history/display/production/' + result.change_id">
                Display Production
              </router-link>
            </td>
            <div v-else>
              <td v-if="result.is_recipe"> 
                <router-link v-bind:to="'/history/display/recipe/' + result.change_id">
                  Display New Recipe Information
                </router-link>
              </td>
              <td v-else> 
                <router-link v-bind:to="'/history/display/resource/' + result.change_id">
                  Display New Resource Information
                </router-link>
              </td>
            </div>
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
          <tr v-for="result in results" :key="result.changed_time">
            <td v-if="result.is_production">
              (Starting) Production in Recipe <router-link v-bind:to="'/history/recipe/' + result.id">
                {{ result.changed_name }}
              </router-link>
            </td><div v-else>
              <div v-if="result.is_recipe">
                <td>
                  Recipe <router-link v-bind:to="'/history/recipe/' + result.id">
                    {{ result.changed_name }}
                  </router-link>
                </td>
              </div>
              <div v-else>
                <td>
                  Resource <router-link v-bind:to="'/history/resource/' + result.id">
                    {{ result.changed_name }}
                  </router-link>
                </td>
              </div>
            </div>
            <td>{{ result.changed_time }}</td>
            <td v-if="result.deleted">Deletion</td>
            <td v-else>Creation/Update</td>
            <td v-if="result.is_production">
              <router-link v-bind:to="'/history/display/production/' + result.change_id">
                Display Production
              </router-link>
            </td>
            <div v-else>
              <td v-if="result.is_recipe"> 
                <router-link v-bind:to="'/history/display/recipe/' + result.change_id">
                  Display New Recipe Information
                </router-link>
              </td>
              <td v-else> 
                <router-link v-bind:to="'/history/display/resource/' + result.change_id">
                  Display New Resource Information
                </router-link>
              </td>
            </div>
          </tr>
          <tr><td>
              <button v-on:click="lastResults">Back</button>
          </td></tr>
        </div><div v-else-if="results.length == 0 && this.page > 0">
          <tr><td>No more history..</td></tr>
          <tr><td>
              <button v-on:click="lastResults">Back</button>
          </td></tr>
        </div><div v-else>
          <tr v-for="result in results" :key="result.changed_time">
            <td v-if="result.is_production">
              (Starting) Production in Recipe <router-link v-bind:to="'/history/recipe/' + result.id">
                {{ result.changed_name }}
              </router-link>
            </td><div v-else>
              <div v-if="result.is_recipe">
                <td>
                  Recipe <router-link v-bind:to="'/history/recipe/' + result.id">
                    {{ result.changed_name }}
                  </router-link>
                </td>
              </div>
              <div v-else>
                <td>
                  Resource <router-link v-bind:to="'/history/resource/' + result.id">
                    {{ result.changed_name }}
                  </router-link>
                </td>
              </div>
            </div>
            <td>{{ result.changed_time }}</td>
            <td v-if="result.deleted">Deletion</td>
            <td v-else>Creation/Update</td>
            <td v-if="result.is_production">
              <router-link v-bind:to="'/history/display/production/' + result.change_id">
                Display Production
              </router-link>
            </td>
            <div v-else>
              <td v-if="result.is_recipe"> 
                <router-link v-bind:to="'/history/display/recipe/' + result.change_id">
                  Display New Recipe Information
                </router-link>
              </td>
              <td v-else> 
                <router-link v-bind:to="'/history/display/resource/' + result.change_id">
                  Display New Resource Information
                </router-link>
              </td>
            </div>
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
      result_limit: 10,
      page: 0,
      error: "",
      state: "loading"
    };
  },
  computed: {
    username: function () {
      return this.$route.path.split("/")[3];
    }
  },
  methods: {
    compare_times (first,second) {
      if (first.changed_time > second.changed_time) {return 0;} else {return 1;}
    },
    async loadHistory() {
      var changes = [];
      try {
        changes = await fetch('http://10.152.152.11:3000/recipes_history?changed_user=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' 
          + this.result_limit + '&offset=' + this.result_limit*this.page)
            .then(response => response.json());
        changes = changes.concat(await fetch('http://10.152.152.11:3000/production_history?changed_user=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' + this.result_limit
          + '&offset=' + this.result_limit*this.page 
          + '&select=change_id,id,recipe_id(recipe_name),changed_user,deleted,changed_time')
            .then(response => response.json()));
        changes = changes.concat(await fetch('http://10.152.152.11:3000/starting_production_history?changed_user=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' + this.result_limit
          + '&offset=' + this.result_limit*this.page
          + '&select=change_id,id,recipe_id(recipe_name),changed_user,deleted,changed_time')
            .then(response => response.json()));
        changes = changes.concat(await fetch('http://10.152.152.11:3000/resources_history?changed_user=eq.' 
          + this.$route.path.split("/")[3] + '&order=changed_time&limit=' + this.result_limit
          + '&offset=' + this.result_limit*this.page)
            .then(response => response.json()));
        this.state = "ready";
      } catch (err) {
        this.error = err;
        this.state = "error";
      }
      changes = changes.sort(this.compare_times);
      console.log(changes);
      for (var i=0; i<changes.length; i++) {
        var change = {
          id: changes[i].id,
          change_id: changes[i].change_id,
          deleted: changes[i].deleted,
          changed_time: changes[i].changed_time
        };
        if (changes[i].recipe_id) {
          change.is_production = true;
          // The following introduces a bug when the recipe is gone
          change.changed_name = changes[i].recipe_id.recipe_name;
        } else {
          change.is_production = false;
        }
        if (changes[i].recipe_name) {
          change.is_recipe = true;
          change.changed_name = changes[i].recipe_name;
          console.log(changes[i].recipe_name);
        } else {
          change.is_recipe = false;
        }
        if (changes[i].resource_name) {
          change.is_resource = true;
          change.changed_name = changes[i].resource_name;
        } else {
          change.is_resource = false;
        }
        this.results.push(change);
        console.log(change);
      }
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
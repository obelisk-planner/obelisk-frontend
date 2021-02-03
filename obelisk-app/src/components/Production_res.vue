<template>
    <tr>
      <th>
         <router-link v-bind:to="'/resource/' + this.production.resource.id">{{ production.resource.resource_name }}</router-link>
      </th>
      <td>{{ production.production }} {{ production.resource.measurement_unit }}/week</td>
      <div v-if="user_jwt.name">
        <td v-if="!deleting"><button v-on:click="deleting=true">Delete</button></td>
        <td v-else>
          <p>Are you sure?</p>
          <button v-on:click="deleting=false">No</button>
          <button v-on:click="delete_production">Yes</button>
        </td>
      </div>
    </tr>
</template>

<script>
export default {
  props: ["production","user_jwt"],
  data() {
    return {
      deleting: false
    };
  },
  methods: {
    async delete_production() {
      try{
        fetch(`http://10.152.152.11:3000/rpc/remove_production`, {
          method: 'POST',
          body: "{\"selected_id\":\"" + this.production.id + "\"}",
          headers: {
            'Content-Type': 'application/json;charset=utf-8',
            'Authorization': 'Bearer ' + this.user_jwt.jwt
          }
        });
        this.$emit('please-reload');
      } catch (err) {
        console.log(err);
      }
    }
  }
};
</script>
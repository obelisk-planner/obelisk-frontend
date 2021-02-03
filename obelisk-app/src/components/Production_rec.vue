<template>
    <tr>
      <th>
        <router-link v-bind:to="'/recipe/' + this.production.recipe.id">{{ production.recipe.recipe_name }}</router-link>
      </th>
      <td>{{ production.production }} {{ production.recipe.unit }}/week</td>
    </tr>
</template>

<script>
export default {
  props: ["production"],
  methods: {
  //  navigate() {
  //    this.$emit('pressed', this.production.recipe_id);
  //  }
  }
};
</script>
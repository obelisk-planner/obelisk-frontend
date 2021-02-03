<template>
    <tr>
      <td>
         <router-link v-bind:to="'/recipe/' + this.recipe.id">{{ recipe.recipe_name }}</router-link>
      </td>
    </tr>
</template>

<script>
export default {
  props: ["recipe"]
};
</script>
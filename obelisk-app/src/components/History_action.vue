<template>
    <tr>
      <td>
         <router-link v-bind:to="'/recipe/' + this.recipe.id">{{ recipe.recipe_name }}</router-link> 
      </td>
      <td v-if="action.deleting == true">
         <button v-on:click="undelete">Undo</button>
      </td>
    </tr>
</template>

<script>
export default {
  props: ["action"]
};
</script>
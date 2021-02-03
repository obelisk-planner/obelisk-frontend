import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Recipe from '../views/Recipe.vue'
import Resource from '../views/Resource.vue'
import Rand_resource from '../views/Rand_resource.vue'
import Rand_recipe from '../views/Rand_recipe.vue'
import Search_recipes from '../views/Search_recipes.vue'
import Search_resources from '../views/Search_resources.vue'
import Recipe_form from '../views/Recipe_form.vue'
import Resource_form from '../views/Resource_form.vue'
import Redirect from '../views/Redirect.vue'
import Login_page from '../views/Login.vue'
import Add_user_page from '../views/New_user.vue'
import Recipe_history from '../views/History_recipe.vue'
import Resource_history from '../views/History_resource.vue'
import User_history from '../views/History_user.vue'
import Recipe_snapshot from '../views/Recipe_snapshot.vue'
import Resource_snapshot from '../views/Resource_snapshot.vue'
import Production_snapshot from '../views/Production_snapshot.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    // To reload without clearing the sidebar.
    path: '/r/:pathMatch(.*)*',
    name: 'Redirect',
    component: Redirect
  },
  {
    path: '/about',
    name: 'About',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/About.vue')
  },
  {
    path: '/newuser',
    name: 'Add_user_page',
    component: Add_user_page
  },
  {
    path: '/login',
    name: 'Login_page',
    component: Login_page
  },
  {
    path: '/recipe/random',
    name: 'Rand_recipe',
    component: Rand_recipe
  },
  {
    path: '/resource/random',
    name: 'Rand_resource',
    component: Rand_resource
  },
  {
    path: '/search/recipe',
    name: 'Search_recipes',
    component: Search_recipes
  },
  {
    path: '/search/resource',
    name: 'Search_resources',
    component: Search_resources
  },
  {
    path: '/recipe:pathMatch(.*)*',
    name: 'Recipe',
    component: Recipe
  },
  {
    path: '/resource:pathMatch(.*)*',
    name: 'Resource',
    component: Resource
  },
  {
    path: '/form/recipe:pathMatch(.*)*',
    name: 'Recipe_form',
    component: Recipe_form
  },
  {
    path: '/form/resource:pathMatch(.*)*',
    name: 'Resource_form',
    component: Resource_form
  },
  {
    path: '/history/recipe:pathMatch(.*)*',
    name: 'Recipe_history',
    component: Recipe_history
  },
  {
    path: '/history/resource:pathMatch(.*)*',
    name: 'Resource_history',
    component: Resource_history
  },
  {
    path: '/history/user:pathMatch(.*)*',
    name: 'User_history',
    component: User_history
  },
  {
    path: '/history/display/recipe:pathMatch(.*)*',
    name: 'Recipe_snapshot',
    component: Recipe_snapshot
  },
  {
    path: '/history/display/resource:pathMatch(.*)*',
    name: 'Resource_snapshot',
    component: Resource_snapshot
  },
  {
    path: '/history/display/production:pathMatch(.*)*',
    name: 'Production_snapshot',
    component: Production_snapshot
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router

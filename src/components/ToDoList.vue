<script>
export default {
  name: "questionList",
  data: () => ({
    questions: [],
    free_phones: [],
    enableMultiSelect: false,
    action: '', // can only be ADD or EDIT
    ADD: 'Add',
    EDIT: 'Edit',
    editedItem: {},
    searchItem: {},
    showMenu: false,
    question: "",
    showDelConfirm: false,
    showSearch: false,
    showSnackbar: false,
    showEditDialog: false,
    showSearchResult: false,
    showNewQuestion: false,
    snackbarText: '',
    searchedResult: {},
    newPhone: "",
    free_phones: [],
  }),
  mounted() {
    this.fetchQuestions()
    this.getFreePhones()
  },
  watch: {
  },
  computed: {
  },
  methods: {
    fetchQuestions() {
      this.axios.get('/api/questions')
          .then(response => {
            this.questions = response.data
          })
          .catch(error => {
            console.log(error)
            this.questions = []
          })
    },
    newLanguage(language) {
      const body = {
        description: this.question.prompt,
        uuid: this.question.uuid
      }
      this.notify(body)
      this.axios.post('/api/question/' + language, body)
        .then(response => {
          this.notify(response.data)
        })
        .catch(error => {
          console.log(error)
        })
    },
    sendNewPhone() {
      this.axios.post(`/api/new_phone/${this.newPhone}`)
        .then(response => {
          console.notify(response.data)
          this.getFreePhones()
        })
        .catch(error => {
          console.log(error)
          // this.free_phones = []
        })
        this.showSearch = false;
    },
    formatResults() {
      return `🗳️ Voting Results: Yes ➤ ${this.question.yes} votes | No ➤ ${this.question.no} votes`;
    },
    formatQuestion() {
      return `Question: ${this.question.prompt}`;
    },
    notify(msg) {
      this.snackbarText = msg
      this.showSnackbar = true
    },
    getSelectedItems() { // not in computed because it doesn't need to be reactive
      const selectedItems = this.questions.filter(item => item.selected)
      return selectedItems
    },

    showEdit(item) { 
      this.question = item
      this.showEditDialog = true
    },

    searchItemById(id) {
      console.log(id)
      this.axios.get('/list/' + id)
        .then(response => {
          this.showSearchResult = true 
          this.searchedResult = response.data
        })
        .catch(error => {
          this.notify("Failed to search the item")
          this.showSearchResult = true 
          this.searchedResult.name = "test"
          this.searchedResult.description = "test"
        })
      this.showSearch = false
    },
    getFreePhones() {
      this.axios.get('/api/free_phones')
        .then(response => {
          this.free_phones = response.data
        })
        .catch(error => {
          console.log(error)
          // this.free_phones = []
        })
    },
    newQuestion(item) {
      const body = {
        description: item.description,
        uuid: "empty"
      }
      this.axios.post('/api/question', body)
          .then(response => {
            this.notify(response.data)
            this.fetchQuestions()
          })
          .catch(error => {
            this.notify(error)
          })
      this.showNewQuestion = false 
    },
    formatTitle(question) {
      return `👍 Vote "Yes": Call 📞 ${question.voteYesPhone} | 👎 Vote "No": Call 📞 ${question.voteNoPhone}`;
    },
    addQuestion(question) {
      const body = {
        description: question.description,
      }
      this.axios.post('/api/questions', body)
          .then(response => {
            this.notify('Question added')
            this.fetchQuestions()
          })
          .catch(error => {
            this.notify(error)
            // for offline testing
          })
      this.showEditDialog = false
      console.log("add")
    },
    _delItem(id) { // only used internally
      this.axios.delete('/list/' + id)
          .then(response => {
            this.notify('Item deleted')
          })
          .catch(error => {
            this.notify('Error deleting item')
          })
    },
    delItems() {
      const items = this.getSelectedItems() 
      items.forEach(item => {
        this._delItem(item.id)
      })
      this.questions = this.questions.filter(item => !items.includes(item)) // for offline testing
      this.fetchQuestions()
      this.showDelConfirm = false
    },
    checkItem(item) {
      item.done = !item.done
      if (item.done) {
        this.axios.put("incomplete/" + item.id)
          .then(response => {
            this.notify("item " + item.id + " checked")
          })
          .catch(error => {
            this.notify("failed to check the item")
          })
      } else {
        this.axios.put("complete/" + item.id)
          .then(response => {
            this.notify("item " + item.id + " unchecked")
          })
          .catch(error => {
            this.notify("failed to uncheck the item")
          })
      }
    },
    toggleMultiSelect() {
      this.enableMultiSelect = !this.enableMultiSelect
      this.showMenu = false
    },
  }
}
</script>

<template>
  <v-card
      class="mx-auto"
      max-width="600"
  >
    <v-toolbar color="secondary">
      <v-toolbar-title>Questions</v-toolbar-title>

      <v-spacer></v-spacer>

      <v-btn @click="showSearch = true" variant="text" icon="mdi-phone"></v-btn>
<!--      question: search-->

      <v-dialog v-model="showSearch" width="30%">
        <v-card>
        <v-card-title>Available Phones</v-card-title>
        <v-card-text v-for="phone in free_phones">
            📞 {{ phone.phone }}
        </v-card-text>
        <v-card-text>
          <v-text-field label="Phone number"
                        v-model="newPhone"
          ></v-text-field>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
              color="red"
              @click="showSearch = false"
          >
            Close
          </v-btn>
          <v-btn
              color="green"
              @click="sendNewPhone()"
          >
            Add 
          </v-btn>
        </v-card-actions>
      </v-card>
      </v-dialog>


      <v-dialog v-model="showAddQuestion" width="30%">
        <v-card>
        <v-card-title>Available Phones</v-card-title>
        <v-card-text v-for="phone in free_phones">
            📞 {{ phone.phone }}
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
              color="red"
              @click="showSearch = false"
          >
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
      </v-dialog>


      <v-dialog v-model="showSearchResult"
                width="auto"
      >
        <v-card>
          <v-card-text>The item you searched for:</v-card-text>
          <v-card-text>name: {{ searchedResult.name }}</v-card-text>
          <v-card-text>description: {{ searchedResult.description }}</v-card-text>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn
                color="green"
                @click="showSearchResult = false"
            >
              OK
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
      
      <v-btn icon="mdi-plus"
             @click="showNewQuestion = true"
      ></v-btn>
<!--      reusing the same dialog for add and edit-->
    </v-toolbar>

    <v-dialog v-model="showNewQuestion"
                    width="30%"
    >
      <v-card>
        <v-card-title>Add new question</v-card-title>
        <v-card-text>
          <v-text-field label="Description"
                        v-model="editedItem.description"
          ></v-text-field>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
              color="red"
              @click="showNewQuestion= false"
          >
            Cancel
          </v-btn>
          <v-btn
              color="green"
              @click="newQuestion(editedItem)"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>


    <v-dialog v-model="showEditDialog"
                    width="30%"
    >
      <v-card>
        <v-card-title> Question Details </v-card-title>
        <v-card-text>
          {{ formatQuestion() }}
        </v-card-text>
        <v-card-text>
          {{ formatResults() }}
        </v-card-text>
        <v-btn @click="newLanguage(`french`)">
          French 
        </v-btn>
        <v-btn @click="newLanguage(`bambara`)">
          Bambara
        </v-btn>
        <v-btn @click="newLanguage(`bobo`)">
          Bobo
        </v-btn>
        <v-btn @click="newLanguage(`fula`)">
          Fula
        </v-btn>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
              color="green"
              @click="showEditDialog = false"
          >
            Ok
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-list lines="two">
      <v-list-item
          v-for="question in questions"
          :key="question.id"
          :title="question.prompt"
          :subtitle="formatTitle(question)"
      >
        <template v-slot:append>
          <v-btn
              icon=" mdi-eye-outline"
              @click="showEdit(question)"
          ></v-btn>
          
        </template>
      </v-list-item>
      
<!--      notification snackbar for all actions-->
      <v-snackbar
          v-model="showSnackbar"
      >
        {{ snackbarText }}
        <template v-slot:actions>
          <v-btn
              color="pink"
              variant="text"
              @click="showSnackbar = false"
          >
            Close
          </v-btn>
        </template>
      </v-snackbar>
      
<!--      only show this toolbar when in multi select mode -->
      <div>
        <v-toolbar v-if="enableMultiSelect"
                   width="50%">
          <v-btn icon="mdi-delete"
                 @click="showDelConfirm = true"
          ></v-btn>
          <!--      question: multi check-->
<!--          question: center btns-->


          <v-spacer></v-spacer>

          <v-btn icon="mdi-check"
                 @click="toggleMultiSelect()"
          ></v-btn>
        </v-toolbar>
      </div>
    </v-list>
    
  </v-card>
</template>

<style scoped>

</style>
$(document).on("turbolinks:load", function() {
  tinymce.init({
    selector: 'textarea.tinymce',
    plugins: 'lists',
    width : '100%',
    toolbar: 'bold italic numlist bullist',
    menubar: false
  })
})

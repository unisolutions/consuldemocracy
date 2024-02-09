// Overrides and adds customized javascripts in this file
// Read more on documentation:
// * English: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_EN.md#javascript
// * Spanish: https://github.com/consuldemocracy/consuldemocracy/blob/master/CUSTOMIZE_ES.md#javascript
//
//

(function() {
  "use strict";
  console.log('asdsadsa');
  App.dropdown = {
    initialize: function() {
      $("#budget_investment_group_id").change(function () {
        alert('asd');

        var groupId = $(this).val();
        console.log("hello");
        $.ajax({
          url: '/investments/update_heading_options',
          type: 'GET',
          dataType: 'json',
          data: { group_id: groupId },
          success: function(data) {
            // Update the options in the second dropdown
            $('#budget_investment_heading_id').html(data.options);
          },
          error: function(xhr, status, error) {
            console.error(error);
          }
        });
      });
    }
  };
}).call(this);

$(document).ready(function() {
  console.log('sadsadsad');
  // Select the #mySelect element and attach a change event handler
  $('#budget_investment_group_id').on('change', function() {
    // Get the selected value
    var selectedValue = $(this).val();

    // Show an alert with the selected value
    alert('Selected value: ' + selectedValue);
  });
});

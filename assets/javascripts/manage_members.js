$(document).find('.button-cancel').hide();
$(document).find('.button-delete').hide();
$(document).find('.button-save').hide();
//TODO Actualmente se elimina correctamente de la tabla, pero falta eliminarlo de la BD (NO HACER POR AHORA)
$(document).on('click', '.button-delete', function() {
    $(this).parents('tr').remove();
})
$(document).on('click', '.button-edit', function(event) {
    event.preventDefault();
    var tr = $(this).closest('tr');
    var inputs = tr.find('input');
    inputs.each(function(index, val) {
        $(this).attr('original-entry', $(this).val());
    });
    tr.css("background-color", "#f0f0f0");
    tr.find('input').css("border", "1px solid #862a5c").css("background-color", "white");
    tr.find('.user').css("background-color", "transparent").css("border", "none");
    tr.find('.button-cancel').show();
    tr.find('.button-delete').show();
    tr.find('.button-save').show();
    tr.find('.button-edit').hide();
    tr.find('.start_date').removeAttr("readonly");
    tr.find('.end_date').removeAttr("readonly");
    tr.find('.hour_rate').removeAttr("readonly");
    tr.find('.assigned_hours').removeAttr("readonly");
    tr.find('.comment-members').removeAttr("readonly");
    $(this).focus();
})
$(document).on('click', '.button-cancel', function(event) {
    event.preventDefault();
    var tr = $(this).closest('tr');
    var original_inputs = tr.find('input');
    original_inputs.each(function(index, val) {
        $(this).val($(this).attr('original-entry'));
    });
    tr.css("background-color", "#f9f9f9");
    tr.find('input').css("border", "none").css("background-color", "transparent");
    tr.find('.button-cancel').hide();
    tr.find('.button-delete').hide();
    tr.find('.button-save').hide();
    tr.find('.button-edit').show();
    tr.find('.start_date').attr("readonly", true);
    tr.find('.end_date').attr("readonly", true);
    tr.find('.hour_rate').attr("readonly", true);
    tr.find('.assigned_hours').attr("readonly", true);
    tr.find('.comment-members').attr("readonly", true);
    $(this).focus();
});
// Manejo de tabla del historial de miembros
$(document).find('.table-historic-members').hide();
$(document).find('.button-hide-historic-table').hide();
$(document).on('click', '.button-show-historic-table', function(event) {
    event.preventDefault();
    $(document).find('.table-historic-members').show();
    $(document).find('.button-hide-historic-table').show();
    $(document).find('.button-show-historic-table').hide();
});
$(document).on('click', '.button-hide-historic-table', function(event) {
    event.preventDefault();
    $(document).find('.table-historic-members').hide();
    $(document).find('.button-hide-historic-table').hide();
    $(document).find('.button-show-historic-table').show();
});
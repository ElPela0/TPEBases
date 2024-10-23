db.servicio.aggregate([
{
    $group: {
        _id: "$tipoIntervalo",
        cantidad: {$sum: 1}
    }},{
    $project: {
        _id:1,
        cantidad:1
    }

}]);
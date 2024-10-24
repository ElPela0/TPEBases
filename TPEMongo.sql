db.servicio.aggregate([
{
    $group: {
      _id: "$tipoIntervalo",
      cantidad: { $sum: 1 }
    }
},
{
    $sort: {
      cantidad: 1
    }
}
]);

db.comprobante.aggregate([
{
    $group:{
        _id: "$cliente.idCliente",
        cant: {$sum:1},
        totalFacturacion:{$sum:"$importe"}
    }
},
{
    $match:{
        totalFacturacion:{$gt:250}
    }
},
{
    $sort:{
        totalFacturacion:-1
    }
}
])
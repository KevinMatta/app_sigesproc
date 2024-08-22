class Clientevienwmodel {

         int? clieId;
         String? clieDNI;
         String? clieNombre;
         String? clieApellido;
         String? clieCorreoElectronico;
         String? clieTelefono;
         DateTime? clieFechaNacimiento;
         String? clieSexo;
         String? clieDireccionExacta;
         int? ciudId;
         int? civiId;
         int? usuaCreacion;
         DateTime? clieFechaCreacion;
         int? usuaModificacion;
         DateTime? clieFechaModificacion;
         bool? clieEstado;

         String? codigo;
         String? clieNombreCompleto;
         String? civiDescripcion;
         String? ciudDescripcion;
         String? clieusuaCreacion;
         String? clieusuaModificacion;
         String? clieusuaCreacionn;
         String? clieusuaModificacionn;
         String? clieTipo;
         String? tipoCliente;

         Clientevienwmodel({

          this.codigo,
          this.clieId,
          this.clieDNI,
          this.clieNombre,
          this.clieApellido,
          this.clieCorreoElectronico,
          this.clieTelefono,
          this.clieFechaNacimiento,
          this.clieSexo,
          this.clieDireccionExacta,
          this.ciudId,
          this.civiId,
          this.usuaCreacion,
          this.clieFechaCreacion,
          this.usuaModificacion,
          this.clieFechaModificacion,
          this.clieEstado,


          this.clieNombreCompleto,
          this.civiDescripcion,
          this.ciudDescripcion,
          this.clieusuaCreacion,
          this.clieusuaModificacion,
          this.clieusuaCreacionn,
          this.clieusuaModificacionn,
          this.clieTipo,
          this.tipoCliente

         });

         factory Clientevienwmodel.fromJson(Map<String, dynamic> json){
          return Clientevienwmodel(
            codigo: json['codigo'] ?? '',
            clieId: json[''],
            clieDNI: json[''],
            clieNombre: json[''],
            clieApellido: json[''],
            clieCorreoElectronico: json[''],
            clieTelefono: json[''],
            clieFechaNacimiento: json[''] != null ? DateTime.parse(json['']) : null,
            clieSexo: json[''],
            clieDireccionExacta: json[''],
            
          );
         }

}
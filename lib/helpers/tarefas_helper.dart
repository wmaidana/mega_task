import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String tarefasTable = "tarefasTable";
final String idColumn = "idColumn";
final String tituloColumn = "tituloColumn";
final String statusColumn = "statusColumn";
final String prioridadeColumn = "prioridadeColumn";

class TarefasHelper{
    static final TarefasHelper _instance = TarefasHelper.internal();

    factory TarefasHelper() => _instance;

    TarefasHelper.internal();

    Database _db;

    Future<Database> get db async {
      if(_db != null) return _db;
      else{
        _db = await initDb();
        return _db;
      }
    }

    Future<Database> initDb() async{
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, "tarefas.db");

      return await openDatabase(path, version: 1, onCreate:
          (Database db, int newerVersion) async{
            await db.execute("CREATE TABLE "
                "$tarefasTable($idColumn INTEGER PRIMARY KEY, "
                  "$tituloColumn TEXT,"
                  "$statusColumn TEXT,"
                  "$prioridadeColumn TEXT)");
      });
    }

    Future<Tarefas> saveTarefa(Tarefas tarefa) async{
        Database dbTarefas = await db;
        tarefa.id = await dbTarefas.insert(tarefasTable, tarefa.toMap());
        return tarefa;
    }

    // ignore: missing_return
    Future<Tarefas> getTarefa(int id) async{
      Database dbTarefas = await db;
      List<Map> maps = await dbTarefas.query(tarefasTable, columns: [idColumn,
        tituloColumn, statusColumn, prioridadeColumn],
        where: "$idColumn = ?", whereArgs: [id]);
      
      if(maps.length > 0){
        return Tarefas.fromMap(maps.first);
      }
    }
    
    Future<int> deleteTarefa(int id) async{
      Database dbTarefas = await db;
      return await dbTarefas.delete(tarefasTable,
          where: "$idColumn = ?", whereArgs: [id]);
    }

    // ignore: missing_return
    Future<Tarefas> updateTarefa(Tarefas tarefa) async{
      Database dbTarefas = await db;
      dbTarefas.update(tarefasTable, tarefa.toMap(),
        where: "$idColumn = ?", whereArgs: [tarefa.id]);
    }

    // ignore: missing_return
    Future<List> getTarefas(String sts, String priority) async{
      Database dbTarefas = await db;
      List<Tarefas> listTarefas = List<Tarefas>();

      if(sts == "Todas"){
        try{
          List listMap = await dbTarefas.rawQuery("SELECT * FROM $tarefasTable"
              " WHERE $prioridadeColumn = '$priority'");
          for(Map m in listMap)
            listTarefas.add(Tarefas.fromMap(m));
        } catch (e){
          e.toString();
        }
        return listTarefas;
      }
      else if(sts.isNotEmpty){
        try{
          List listMap = await dbTarefas.rawQuery("SELECT * FROM $tarefasTable"
              " WHERE $prioridadeColumn = '$priority' "
              "AND $statusColumn = '$sts'");
          for(Map m in listMap) listTarefas.add(Tarefas.fromMap(m));
        } catch (e){
          e.toString();
        }
        return listTarefas;
      }
    }

    Future close() async{
      Database dbTarefas = await db;
      dbTarefas.close();
    }
}

class Tarefas {
    int id;
    String titulo;
    String status;
    String prioridade;

    Tarefas();

    Tarefas.fromMap(Map map){
      id = map[idColumn];
      titulo = map[tituloColumn];
      status = map[statusColumn];
      prioridade = map[prioridadeColumn];
    }

    Map toMap(){
      Map<String, dynamic> map = {
        tituloColumn: titulo,
        statusColumn: status,
        prioridadeColumn: prioridade
      };
      if(id != null){
        map[idColumn] = id;
      }
      return map;
    }

    @override
    String toString() {
      return "Tarefa(id: $id, titulo: $titulo, status: $status, prioridade: $prioridade)";
    }



}
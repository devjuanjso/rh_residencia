from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('projetos', '0003_projeto_data_inicio_projeto_tipo'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='projeto',
            name='rascunho',
        ),
        migrations.AddField(
            model_name='projeto',
            name='status',
            field=models.CharField(
                choices=[('rascunho', 'Rascunho'), ('publicado', 'Publicado'), ('encerrado', 'Encerrado')],
                default='rascunho',
                max_length=20,
            ),
        ),
    ]

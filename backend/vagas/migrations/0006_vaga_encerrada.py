from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vagas', '0005_remove_vaga_descricao'),
    ]

    operations = [
        migrations.AddField(
            model_name='vaga',
            name='encerrada',
            field=models.BooleanField(default=False),
        ),
    ]

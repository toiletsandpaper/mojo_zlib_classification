from tool.gzip_python import compress, decompress, CompressedText
from collections.optional import Optional

trait BaseClassifier:
    fn train(inout self, texts: DynamicVector[CompressedText[]], k: Int = 1) raises -> None: pass
    fn classify(self, text: CompressedText[], k: Optional[Int] = None) raises -> CompressedText: pass
    fn classify_bulk(self, texts: DynamicVector[CompressedText[]], k: Optional[Int] = None) raises -> DynamicVector[CompressedText[]]: pass


    # @property
    # def is_ready(self):
    #     return len(self._model) > 0

    # @property
    # def model_settings(self):
    #     """ An optional value to serialize settings for this model
    #     into the model output for use later.

    #     Once imported from a source, these settings are re-applied to the
    #     classifier.
    #     """
    #     return {}

    # @property
    # def model(self):
    #     """ A writeable version of the data model for this classifier. """
    #     if not self.is_ready:
    #         raise ValueError('Cannot export un-trained model.')

    #     def _encode(item):
    #         if isinstance(item, bytes):
    #             return b64encode(item).decode('utf-8')
    #         else:
    #             return b64encode(str(item).encode('utf-8')).decode('utf-8')

    #     settings = [
    #         f'# Gzip Classifier Model Version {self.version}',
    #         f'# This file contains model data with the following settings:',
    #         f'#',
    #         f'# {json.dumps(self.model_settings)}',
    #     ]

    #     model_data = [
    #         ' '.join([_encode(item) for item in row])
    #         for row in self._model
    #     ]

    #     return '\n'.join([
    #         *settings,
    #         *model_data,
    #     ]).encode('utf-8')

    # @model.setter
    # def model(self, value: bytes):
    #     """ Update the data model for this classifier. """

    #     def _decode(row: [bytes]):
    #         items = [b64decode(item) for item in row]
    #         return (
    #             items[0],
    #             items[1],
    #             float(items[2]),
    #             items[3].decode('utf-8'),
    #         )

    #     def _is_configuration(row: bytes):
    #         return row[0] == '#'

    #     def _configure(row: bytes):
    #         try:
    #             config = json.loads(row[1:])
    #         except json.JSONDecodeError:
    #             # This line does not contain model settings data. It could
    #             # be a comment.
    #             return

    #         for setting in self.model_settings:
    #             if value := config.get(setting):
    #                 setattr(self, setting, value)

    #     for row in value.decode('utf-8').split('\n'):
    #         if _is_configuration(row):
    #             _configure(row)
    #         else:
    #             self._model.append(_decode(row.split()))

    # @property
    # def compact_model(self):
    #     """ The same as `model` but the returned value is already gzipped for
    #     easy storage on disk.
    #     """
    #     return compress(self.model)

    # @compact_model.setter
    # def compact_model(self, value):
    #     """ Set the model to a value exported from `compact_model`. """
    #     self.model = decompress(value)
